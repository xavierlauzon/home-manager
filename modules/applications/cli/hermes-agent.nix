{config, inputs, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.hermes-agent;

  hermesAgentPkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent;

  # numtide's hermes-agent is built against nixpkgs mcp 1.29.0, but Hermes
  # v0.22.x expects mcp 2.x (mcp.server.MCPServer). The sitecustomize shim
  # aliases MCPServer -> FastMCP (same API); PYTHONPATH makes it load for
  # `hermes mcp serve` (Hermes' entrypoint adds deps via site.addsitedir,
  # which the shim patches after startup).
  hermesMcpWrapper = pkgs.writeShellScriptBin "hermes-mcp" ''
    export PYTHONPATH="$HOME/.local/lib/hermes-patch''${PYTHONPATH:+:$PYTHONPATH}"
    exec ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent}/bin/hermes mcp serve "$@"
  '';
in
with lib;
{
  options = {
    host.home.applications.hermes-agent = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Nous Research Hermes Agent (open-source autonomous terminal AI agent).";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      hermesAgentPkg
      hermesMcpWrapper
    ];

    # Daemonize the Hermes messaging gateway as a systemd user service so it
    # persists (and the Hermes cron keeps firing) without a manual `hermes
    # gateway start`. Declarative: rebuildable, starts at login, auto-restarts.
    systemd.user.services.hermes-gateway = {
      Unit = {
        Description = "Hermes Agent Gateway - Messaging Platform Integration";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${hermesAgentPkg}/bin/hermes gateway run";
        WorkingDirectory = "${config.home.homeDirectory}/.hermes";
        Environment = [
          "HERMES_HOME=${config.home.homeDirectory}/.hermes"
          "HERMES_SUPERVISED_CHILD=1"
        ];
        Restart = "always";
        RestartSec = "5";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    home.file.".local/lib/hermes-patch/sitecustomize.py".text = ''
      # Shim: numtide's hermes-agent is built against nixpkgs mcp 1.29.0, where the
      # server class is mcp.server.fastmcp.FastMCP (renamed to MCPServer in mcp 2.0).
      # Hermes' entrypoint adds deps via site.addsitedir() AFTER interpreter startup,
      # so patch addsitedir and alias MCPServer as soon as mcp becomes importable.
      import site as _site

      _orig_addsitedir = _site.addsitedir


      def _addsitedir_patched(*args, **kwargs):
          ret = _orig_addsitedir(*args, **kwargs)
          try:
              import mcp.server as _ms
              from mcp.server.fastmcp import FastMCP
              if not hasattr(_ms, "MCPServer"):
                  _ms.MCPServer = FastMCP
          except Exception:
              pass
          return ret


      _site.addsitedir = _addsitedir_patched
    '';
  };
}

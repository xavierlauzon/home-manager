{config, inputs, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.hermes-agent;
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
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent
    ];
  };
}

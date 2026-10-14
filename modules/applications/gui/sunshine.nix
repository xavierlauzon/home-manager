{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.sunshine;

  displayServer = config.host.home.feature.gui.displayServer;
  windowManager = config.host.home.feature.gui.windowManager;
  isHyprland = config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland";

  vd = cfg.virtualDisplay;

  # Binaries Sunshine's prep-cmds and the bootstrap need at runtime.
  runtimePath = lib.makeBinPath (
    (lib.optional isHyprland config.wayland.windowManager.hyprland.package)
    ++ [ pkgs.coreutils pkgs.gnugrep ]
  );

  # Creates the headless virtual output before Sunshine starts.
  # Sunshine caches `output_name` once at process startup, so the output must
  # already exist or it silently falls back to the primary monitor.
  bootstrap = pkgs.writeShellScript "sunshine-virtual-display-bootstrap" ''
    set -euo pipefail
    export PATH="${runtimePath}:$PATH"

    # Wait for the Hyprland compositor socket.
    for _ in $(seq 1 30); do
      if hyprctl monitors >/dev/null 2>&1; then break; fi
      sleep 0.5
    done

    # Create the headless output if it does not exist yet (idempotent).
    # The declarative Hyprland `monitor` rule in this module applies geometry
    # automatically once the output appears.
    if ! hyprctl monitors -j | grep -q "\"name\": \"${vd.name}\""; then
      hyprctl output create headless ${vd.name} || true
    fi
  '';

  # Resizes the virtual output to match the connecting Moonlight client.
  # Used by the "Second Monitor" app's prep-cmd via SUNSHINE_CLIENT_* vars.
  setVddMode = pkgs.writeShellScript "sunshine-set-vdd-mode" ''
    set -euo pipefail
    export PATH="${runtimePath}:$PATH"
    MODE="''${1:-${vd.mode}}"
    hyprctl eval "hl.monitor({ output = \"${vd.name}\", mode = \"$MODE\", position = \"${vd.position}\", scale = 1 })"
  '';
in
with lib;
{
  options = {
    host.home.applications.sunshine = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Sunshine self-hosted game stream server (host)";
      };

      service = {
        enable = mkOption {
          default = true;
          type = with types; bool;
          description = "Run Sunshine as a user service at session start";
        };
      };

      # The Hyprland virtual display that Moonlight streams — the Linux
      # equivalent of the Windows Virtual Display Driver (VDD) "ghost monitor".
      virtualDisplay = {
        enable = mkOption {
          default = true;
          type = with types; bool;
          description = "Create a headless Hyprland output for the second monitor";
        };
        name = mkOption {
          default = "STREAM";
          type = with types; str;
          description = "Name of the headless output";
        };
        mode = mkOption {
          default = "2560x1440@120";
          type = with types; str;
          description = "Default virtual display mode (WIDTHxHEIGHT@REFRESH). 2x the target stream FPS gives clean frame pacing.";
        };
        position = mkOption {
          default = "auto-right";
          type = with types; str;
          description = ''
            Layout position of the virtual display.

            NOTE (known Sunshine issue #3696): absolute mouse input from the client
            currently ignores multi-monitor offsets and always lands at host (0,0).
            If the mouse doesn't track on the stream, set this to "0x0" and move
            your physical monitor to "<virtualWidth>x0" instead.
          '';
        };
      };

      # Host-side stream settings (mirrors the Windows virtual-monitor setup).
      settings = mkOption {
        default = { };
        type = with types; attrsOf str;
        description = "Extra sunshine.conf keys (overrides module defaults)";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.unstable.sunshine
    ];

    # Declarative config — the web UI becomes read-only, which is what we want.
    xdg.configFile."sunshine/sunshine.conf".text = ''
      sunshine_name = blackhawk
      capture = wlr
      output_name = ${vd.name}
      encoder = vaapi
      stream_audio = disabled
      min_log_level = 2
      origin_web_ui_allowed = lan
      upnp = disabled
      lan_encryption_mode = 1
      port = 47989
    '' + (lib.concatStrings (lib.mapAttrsToList (k: v: "${k} = ${v}\n") cfg.settings));

    xdg.configFile."sunshine/apps.json".text = builtins.toJSON {
      # "env" is REQUIRED by Sunshine's GameStream /applist parser (Boost
      # ptree throws "No such node (env)" if absent -> client sees empty list
      # while the web UI still shows apps). Must come before "apps".
      env = { };
      apps = [
        {
          name = "Second Monitor";
          file = "/run/current-system/sw/bin/true";
          auto-detach = true;
          wait-all = true;
          image-path = "desktop.png";
          prep-cmd = [
            {
              do = "${setVddMode} \"$SUNSHINE_CLIENT_WIDTH\"x\"$SUNSHINE_CLIENT_HEIGHT\"@\"$SUNSHINE_CLIENT_FPS\"";
              undo = "${setVddMode}";
            }
          ];
        }
        {
          name = "Desktop";
          image-path = "desktop.png";
        }
      ];
    };

    # Start Sunshine with the virtual display already present.
    systemd.user.services.sunshine = mkIf cfg.service.enable {
      Unit = {
        Description = "Sunshine game stream server";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "exec";
        ExecStartPre = "${bootstrap}";
        ExecStart = "${pkgs.unstable.sunshine}/bin/sunshine";
        Restart = "on-failure";
        RestartSec = "5s";
        LimitNOFILE = 65536;
        Slice = "app-graphical.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Declare the virtual monitor geometry (applies when the headless output
    # is created at runtime by the bootstrap). mkMerge-safe with displays.nix.
    wayland.windowManager.hyprland.settings = mkIf (isHyprland && vd.enable) {
      monitor = [
        {
          output = vd.name;
          mode = vd.mode;
          position = vd.position;
          scale = 1;
        }
      ];
    };
  };
}

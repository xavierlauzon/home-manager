{ config, inputs, lib, pkgs, ... }:
let
  cfg = config.host.home.applications.dms;
  lua = lib.generators.mkLuaInline;
in
with lib;
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.danksearch.homeModules.dsearch
    inputs.dms-plugin-registry.nixosModules.default
  ];

  options = {
    host.home.applications.dms = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Dank Material Shell.";
      };
    };
  };


  config = mkIf cfg.enable {
    programs = {
      dank-material-shell = {
        enable = true;
        systemd = {
          enable = mkDefault true;
          restartIfChanged = mkDefault true;
        };

        enableSystemMonitoring = mkDefault true;     # System monitoring widgets (dgop)
        enableVPN = mkDefault true;                  # VPN management widget
        enableDynamicTheming = mkDefault true;       # Wallpaper-based theming (matugen)
        enableAudioWavelength = mkDefault true;      # Audio visualizer (cava)
        enableCalendarEvents = mkDefault true;       # Calendar integration (khal)
        enableClipboardPaste = mkDefault true;       # Pasting items from the clipboard (wtype)

        #plugins = {
          #dankBatteryAlerts.enable = true;
          #dankBatteryAlerts.src = inputs.dms-plugin-registry.packages.${pkgs.system}.dankBatteryAlerts;
        #};
        #settings = { # Enable to allow it to export JSON settings https://stevebinary.github.io/json2nix/
        #  theme = "dark";
        #  dynamicTheming = true;
        #};
      };
      dsearch = {
        enable = mkDefault true;
        package = mkDefault pkgs.dsearch;

        config = {
          listen_addr = mkDefault ":43654";

          index_path = mkDefault "~/.cache/danksearch/index";
          max_file_bytes = mkDefault 2097152;  # 2MB
          worker_count = mkDefault 4;
          index_all_files = mkDefault true;

          auto_reindex = mkDefault true;
          reindex_interval_hours = mkDefault 24;

          # Text file extensions
          text_extensions = [
            ".txt" ".md" ".go" ".py" ".js" ".ts"
            ".jsx" ".tsx" ".json" ".yaml" ".yml"
            ".toml" ".html" ".css" ".rs" ".txt" ".conf"
          ];

          # Index paths configuration
          index_paths = [
            {
              path = "~/Documents";
              max_depth = 6;
              exclude_hidden = true;
              exclude_dirs = [ "node_modules" "venv" "target" ];
            }
            {
              path = "~/src";
              max_depth = 8;
              exclude_hidden = true;
              exclude_dirs = [ "node_modules" ".git" "target" "dist" ];
            }
          ];
        };
      };
    };

    # Guard the DMS service: don't start under COSMIC desktop.
    systemd.user.services = {
      dms = {
        Service.ExecCondition = mkDefault "${pkgs.writeShellScript "dms-check-desktop" ''
          case "$XDG_CURRENT_DESKTOP" in
            COSMIC) exit 1;;
            *) exit 0;;
          esac
        ''}";
      };
      #niri-flake-polkit = mkIf niriActive {
      #  Install.WantedBy = mkForce [];
      #};
    };

    wayland.windowManager.hyprland = mkIf cfg.enable {
      settings = {
        # === Application Launchers ===
        bind = [
          { _args = [ "SUPER + D" (lua "hl.dsp.exec_cmd(\"dms ipc call spotlight toggle\")") ]; }
          { _args = [ "SUPER + SHIFT + V" (lua "hl.dsp.exec_cmd(\"dms ipc call clipboard toggle\")") ]; }
          #{ _args = [ "SUPER + M" (lua "hl.dsp.exec_cmd(\"dms ipc call processlist focusOrToggle\")") ]; }
          { _args = [ "SUPER + comma" (lua "hl.dsp.exec_cmd(\"dms ipc call settings focusOrToggle\")") ]; }
          { _args = [ "SUPER + N" (lua "hl.dsp.exec_cmd(\"dms ipc call notifications toggle\")") ]; }
          { _args = [ "SUPER + SHIFT + N" (lua "hl.dsp.exec_cmd(\"dms ipc call notepad toggle\")") ]; }
          #{ _args = [ "SUPER + Y" (lua "hl.dsp.exec_cmd(\"dms ipc call dankdash wallpaper\")") ]; }
          { _args = [ "SUPER + TAB" (lua "hl.dsp.exec_cmd(\"dms ipc call hypr toggleOverview\")") ]; }
          { _args = [ "SUPER + P" (lua "hl.dsp.exec_cmd(\"dms ipc call powermenu toggle\")") ]; }
          # === Cheat sheet ===
          { _args = [ "SUPER + SHIFT + Slash" (lua "hl.dsp.exec_cmd(\"dms ipc call keybinds toggle hyprland\")") ]; }
          # === Security ===
          { _args = [ "SUPER + SHIFT + X" (lua "hl.dsp.exec_cmd(\"dms ipc call lock lock\")") ]; }
          { _args = [ "CTRL + ALT + Delete" (lua "hl.dsp.exec_cmd(\"dms ipc call processlist focusOrToggle\")") ]; }

          { _args = [ "SUPER + SHIFT + W" (lua "hl.dsp.exec_cmd(\"systemctl --user restart dms.service\")") ]; }

          # === Screenshots ===
          #{ _args = [ "Print" (lua "hl.dsp.exec_cmd(\"dms screenshot\")") ]; }
          #{ _args = [ "CTRL + Print" (lua "hl.dsp.exec_cmd(\"dms screenshot full\")") ]; }
          #{ _args = [ "ALT + Print" (lua "hl.dsp.exec_cmd(\"dms screenshot window\")") ]; }

          #{ _args = [ "SUPER + SHIFT + S" (lua "hl.dsp.exec_cmd(\"dms screenshot --no-file --reset\")") ]; }

          # Audio controls (repeating, locked)
          { _args = [ "XF86AudioRaiseVolume" (lua "hl.dsp.exec_cmd(\"dms ipc call audio increment 1\")") { locked = true; repeating = true; } ]; }
          { _args = [ "XF86AudioLowerVolume" (lua "hl.dsp.exec_cmd(\"dms ipc call audio decrement 1\")") { locked = true; repeating = true; } ]; }
          { _args = [ "CTRL + XF86AudioRaiseVolume" (lua "hl.dsp.exec_cmd(\"dms ipc call mpris increment 1\")") { locked = true; repeating = true; } ]; }
          { _args = [ "CTRL + XF86AudioLowerVolume" (lua "hl.dsp.exec_cmd(\"dms ipc call mpris decrement 1\")") { locked = true; repeating = true; } ]; }
          # Brightness controls (repeating, locked)
          { _args = [ "XF86MonBrightnessUp" (lua "hl.dsp.exec_cmd(\"dms ipc call brightness increment 5 \\\"\\\"\")") { locked = true; repeating = true; } ]; }
          { _args = [ "XF86MonBrightnessDown" (lua "hl.dsp.exec_cmd(\"dms ipc call brightness decrement 5 \\\"\\\"\")") { locked = true; repeating = true; } ]; }

          # Audio/mpris toggles (locked)
          { _args = [ "XF86AudioMute" (lua "hl.dsp.exec_cmd(\"dms ipc call audio mute\")") { locked = true; } ]; }
          { _args = [ "XF86AudioMicMute" (lua "hl.dsp.exec_cmd(\"dms ipc call audio micmute\")") { locked = true; } ]; }
          { _args = [ "XF86AudioPause" (lua "hl.dsp.exec_cmd(\"dms ipc call mpris playPause\")") { locked = true; } ]; }
          { _args = [ "XF86AudioPlay" (lua "hl.dsp.exec_cmd(\"dms ipc call mpris playPause\")") { locked = true; } ]; }
          { _args = [ "XF86AudioPrev" (lua "hl.dsp.exec_cmd(\"dms ipc call mpris previous\")") { locked = true; } ]; }
          { _args = [ "XF86AudioNext" (lua "hl.dsp.exec_cmd(\"dms ipc call mpris next\")") { locked = true; } ]; }
        ];
        layer_rule = [
          { match = { namespace = "^dms:.*"; }; no_anim = true; }
          { match = { namespace = "^(quickshell)$"; }; no_anim = true; }
        ];
        window_rule = [
          { match = { class = "^(org.quickshell)$"; }; float = true; }
        ];
      };
    };
  };
}
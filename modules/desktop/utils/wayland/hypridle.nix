{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.hypridle;

  hypridle-companion-script = pkgs.writeShellScriptBin "hypridle-companion" ''
    _hypridle_logfile="$HOME/lock.log"
    HYPRIDLE_DEBUG=''${HYPRIDLE_DEBUG:-"FALSE"}

    _hypridle_exec() {
        if [ "''${HYPRIDLE_DEBUG,,}" = "true" ]; then
            "$@" >> "$_hypridle_logfile"
        else
            "$@"
        fi
    }

    _hypridle_log() {
        if [ "''${HYPRIDLE_DEBUG,,}" = "true" ]; then
            echo "$@"  >> "$_hypridle_logfile"
        else
            echo "$@"
        fi
    }

    case "$1" in
        blank )
            case "$2" in
                before )
                    _hypridle_log "$(date +'%Y-%m-%d %H:%M:%s') [blank] [timeout] 'hyprctl dispatch dpms off'"
                    _hypridle_exec hyprctl dispatch dpms off
                ;;
                after )
                    _hypridle_log "$(date +'%Y-%m-%d %H:%M:%s') [blank] [resume] 'hyprctl dispatch dpms on'"
                    _hypridle_exec hyprctl dispatch dpms on
                ;;
            esac
        ;;
        lock )
            case "$2" in
                before )
                    _hypridle_log "$(date +'%Y-%m-%d %H:%M:%s') [lock] [timeout] 'loginctl lock-session'"
                    _hypridle_exec loginctl lock-session
                ;;
                after )
                    _hypridle_log "$(date +'%Y-%m-%d %H:%M:%s') [lock] [resume]"
                ;;
            esac
        ;;
        suspend )
            case "$2" in
                before )
                    _hypridle_log "$(date +'%Y-%m-%d %H:%M:%s') [suspend] [timeout] 'systemctl suspend'"
                    _hypridle_exec systemctl suspend
                ;;
                after )
                    _hypridle_log "$(date +'%Y-%m-%d %H:%M:%s') [suspend] [resume]"
                ;;
            esac
        ;;
        sleep )
            case "$2" in
                before )
                    _hypridle_log "$(date +'%Y-%m-%d %H:%M:%s') [sleep] [before] 'loginctl lock-session'"
                    _hypridle_exec loginctl lock-session
                ;;
                after )
                    _hypridle_log "$(date +'%Y-%m-%d %H:%M:%s') [after] [after] 'hyprctl dispatch dpms on'"
                    _hypridle_exec hyprctl dispatch dpms on
                ;;
            esac
        ;;
    esac
  '';
in
  with lib;
{
  options = {
    host.home.applications.hypridle = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Hyprland Idle Monitor";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          hypridle-companion-script
        ];
    };

    services = mkIf (config.host.home.feature.gui.displayServer == "wayland" && config.host.home.feature.gui.windowManager == "hyprland" && config.host.home.feature.gui.enable) {
      hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";        # avoid starting multiple hyprlock instances.
            before_sleep_cmd = "$HOME/.local/state/nix/profile/bin/hypridle-companion sleep before";                # lock before suspend.
            after_sleep_cmd = "$HOME/.local/state/nix/profile/bin/hypridle-companion sleep  after";                 # to avoid having to press a key twice to turn on the display.
          };
         listener = [
            {
              timeout = 600;                                                       # 10min
              on-timeout = "$HOME/.local/state/nix/profile/bin/hypridle-companion lock before";                       # lock screen when timeout has passed
            }
            {
              timeout = 660;                                                       # 11min
              on-timeout = "$HOME/.local/state/nix/profile/bin/hypridle-companion blank before";                      # screen off when timeout has passed
              on-resume = "$HOME/.local/state/nix/profile/bin/hypridle-companion blank after";                        # screen on when activity is detected after timeout has fired.
            }
            {
              timeout = 900;                                                       # 15min
              on-timeout = "$HOME/.local/state/nix/profile/bin/hypridle-companion suspend before";                    # suspend pc
            }
          ];
        };
      };
    };
  };
}

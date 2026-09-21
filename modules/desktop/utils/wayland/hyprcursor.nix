{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.hyprcursor;
  cursor = "HyprBibataModernClassicSVG";
  cursorPackage = pkgs.pkg-bibata-hyprcursor;
  cursorSize = 24;
in
  with lib;
{
  options = {
    host.home.applications.hyprcursor = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "hyprcursor is a new cursor theme format that has many advantages over the widely used xcursor.";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      file = {
        ".icons/${cursor}".source = "${cursorPackage}/share/icons/${cursor}";
      };

      packages = with pkgs;
        [
          hyprcursor
        ];

      pointerCursor = {
        enable = true;
        #package = pkgs.bibata-cursors;
        #name = "Bibata-Modern-Classic";
        size = cursorSize;
        gtk.enable = true;
        #x11.enable = true;
      };
    };

    xdg = {
      configFile =
        { "uwsm/env".text = mkIf config.host.home.feature.uwsm.enable
            ''
              export HYPRCURSOR_THEME="${cursor}"
              export HYPRCURSOR_SIZE="${toString cursorSize}"
            '';
        };
        dataFile = {
          "icons/${cursor}".source = "${cursorPackage}/share/icons/${cursor}";
        };
    };

    systemd.user.services.hyprcursor = {
      Unit = {
        Description = "Set Hyprland cursor theme";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.unstable.hyprland}/bin/hyprctl setcursor ${cursor} ${toString cursorSize}";
        RemainAfterExit = true;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    wayland.windowManager.hyprland = {
      settings = {
        env = mkIf (! config.host.home.feature.uwsm.enable) [
          { _args = [ "HYPRCURSOR_THEME" "${cursor}" ]; }
          { _args = [ "HYPRCURSOR_SIZE" "${toString cursorSize}" ]; }
        ];
      };
    };
  };
}
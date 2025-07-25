{ config, inputs, lib, pkgs, ... }:
let
  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;
in
with lib;
{
  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland") {
    wayland.windowManager.hyprland = {
      settings = {
        # UI
        general = {
#          col.active_border = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
#          col.inactive_border = "rgba(b4befecc) rgba(6c7086cc) 45deg";
          allow_tearing = false;
          border_size = 2;
          gaps_in = 3;
          gaps_out = 8;
          layout = "master";
          resize_corner = 2;
          resize_on_border = true;
        };

        cursor = {
          # Cursor
          inactive_timeout = 60;
          hide_on_key_press = false;
        };

        master = {
          allow_small_split = false;
          drop_at_cursor = true;
          inherit_fullscreen = true;
          mfact = 0.50;
          new_on_top = true;
          new_status = "slave";
          orientation = "center";
          smart_resizing = true;
        };

        decoration = {
          blur = {
            enabled = true;
            brightness = 1;
            contrast = 1.0;
            ignore_opacity = true;
            new_optimizations = true;
            passes = 3;
            popups = true;
            size = 6;
            vibrancy = 0.50;
            vibrancy_darkness = 0.50;
            xray = false;
          };
          shadow = {
            enabled = true;
            range = 4;
            render_power = 4;
          };
          dim_inactive = false;
          dim_strength = 0.2;
          rounding = 5;
        };

        animations = {
          enabled = true;
          animation = [
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "windows, 1, 5, myBezier"
            "windowsMove, 1, 5, myBezier"
            "windowsOut, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 20%"
            "workspaces, 1, 10, overshot , slidevert"
          ];
          bezier = [
            "myBezier, 0.05, 0.9, 0.1, 1.1"
            "overshot, 0.05, 0.9, 0.1, 1.1"
          ];
        };
      };
    };
  };
}

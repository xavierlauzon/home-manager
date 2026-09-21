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
        config = {
          general = {
            allow_tearing = false;
            border_size = 2;
            gaps_in = 3;
            gaps_out = 8;
            layout = "master";
            resize_corner = 2;
            resize_on_border = false;
          };

          cursor = {
            inactive_timeout = 60;
            hide_on_key_press = false;
          };

          master = {
            allow_small_split = false;
            drop_at_cursor = true;
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
          };
        };

        curve = [
          {
            _args = [
              "myBezier"
              { type = "bezier"; points = [ [ 0.05 0.9 ] [ 0.1 1.1 ] ]; }
            ];
          }
          {
            _args = [
              "overshot"
              { type = "bezier"; points = [ [ 0.05 0.9 ] [ 0.1 1.1 ] ]; }
            ];
          }
        ];

        animation = [
          { _args = [ { leaf = "border"; enabled = true; speed = 10; bezier = "default"; } ]; }
          { _args = [ { leaf = "fade"; enabled = true; speed = 7; bezier = "default"; } ]; }
          { _args = [ { leaf = "windows"; enabled = true; speed = 5; bezier = "myBezier"; } ]; }
          { _args = [ { leaf = "windowsMove"; enabled = true; speed = 5; bezier = "myBezier"; } ]; }
          { _args = [ { leaf = "windowsOut"; enabled = true; speed = 7; bezier = "myBezier"; } ]; }
          { _args = [ { leaf = "windowsOut"; enabled = true; speed = 7; bezier = "default"; style = "popin 20%"; } ]; }
          { _args = [ { leaf = "workspaces"; enabled = true; speed = 10; bezier = "overshot"; style = "slidevert"; } ]; }
        ];
      };
    };
  };
}

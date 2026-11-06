{ config, inputs, lib, pkgs, specialArgs, ... }:
let
  inherit (specialArgs) displays hostname role;

  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;
in
with lib;
{
  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland") {
    wayland.windowManager.hyprland = {
      settings = mkMerge [
        (mkIf (hostname == "xavierdesktop") {
          monitor = [
            {
              output = "desc:Samsung Electric Company Odyssey G95NC HNTWA00116";
              mode = "7680x2160@240";
              position = "0x0";
              scale = "auto";
              vrr = 1;
              bitdepth = 8;
            }
          ];
        })
        (mkIf (hostname == "blackhawk") {
          monitor = [
            {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = 1;
            }
          ];
        })
        # lightning: two monitors both on the RX 7900 XT dGPU (card1).
        # DP-2 = Dell AW3418DW ultrawide 3440x1440@100 (center/primary);
        # HDMI-A-1 = ViewSonic VX2252 1920x1080@60 (right, above center line).
        (mkIf (hostname == "lightning") {
          monitor = [
            {
              output = "DP-2";
              mode = "3440x1440@100";
              position = "0x0";
              scale = 1;
              vrr = 1;
            }
            {
              output = "HDMI-A-1";
              mode = "1920x1080@60";
              position = "3440x0";
              scale = 1;
            }
          ];
        })
      ];
    };
  };
}
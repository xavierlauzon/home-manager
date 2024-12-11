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
            "DP-3,7680x2160@240,0x0,1.0,bitdepth,8"
            "HDMI-A-2,3840x1080@120,auto-up,1.0"
          ];
        })
      ];
    };
  };
}
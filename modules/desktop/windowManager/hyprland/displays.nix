{ config, inputs, lib, pkgs, specialArgs, ... }:
let
  inherit (specialArgs) displays display_center display_left display_right hostname role;

  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;
in
with lib;
{
  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland") {
    wayland.windowManager.hyprland = {
      settings = mkMerge [
        (mkIf (displays == 1) {
           "$monitor_middle" = "${display_center}";
        })
        (mkIf (displays == 2) {
           "$monitor_middle" = "${display_center}";
           "$monitor_right" = "${display_right}";
        })
        (mkIf (displays == 3) {
           "$monitor_middle" = "${display_center}";
           "$monitor_right" = "${display_right}";
           "$monitor_left" = "${display_left}";
        })
        (mkIf (hostname == "xavierdesktop") {
          monitor = [
            "$monitor_middle,7680x2160@120,auto,1"
          ];
        })
      ];
    };
  };
}
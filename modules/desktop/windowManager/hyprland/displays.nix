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
      ];
    };
  };
}
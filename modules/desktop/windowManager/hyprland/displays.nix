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
            "desc:Samsung Electric Company Odyssey G95NC HNTWA00116, 7680x2160@240, 0x0, auto, vrr, 1, bitdepth, 8"
            "desc:ASUSTek COMPUTER INC ASUS XG49V 0x0002DAE4, 3840x1080@120, 0x-1080, auto, vrr, 1, bitdepth, 8"
          ];
        })
      ];
    };
  };
}
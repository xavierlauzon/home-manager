{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.obsidian;
in
  with lib;
{
  options = {
    host.home.applications.obsidian = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Note taking tool";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          obsidian
        ];
    };

    #nixpkgs.config.permittedInsecurePackages = [
    #    "electron-25.9.0" ## TODO - Added 2023-12-20 due to Electron being marked as Insecure
    #];

    wayland.windowManager.hyprland = mkIf (config.host.home.feature.gui.displayServer == "wayland" && config.host.home.feature.gui.windowManager == "hyprland" && config.host.home.feature.gui.enable) {
      settings = {
        exec-once = [
          "obsidian"
        ];
      };
    };

  };
}

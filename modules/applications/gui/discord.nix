{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.discord;
in
  with lib;
{
  options = {
    host.home.applications.discord = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Discord, VoIP & IM";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          vesktop
          discord
          discord-ptb
          discord-canary
          arrpc
          legcord
        ];
    };

    wayland.windowManager.hyprland = mkIf (config.host.home.feature.gui.displayServer == "wayland" && config.host.home.feature.gui.windowManager == "hyprland" && config.host.home.feature.gui.enable) {
      settings = {
        exec-once = [
          "vesktop"
        ];
      };
    };

    services.arrpc.enable = true;
  };
}

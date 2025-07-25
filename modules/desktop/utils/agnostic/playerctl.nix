{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.playerctl;
in
  with lib;
{
  options = {
    host.home.applications.playerctl = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Media Keys tool";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          playerctl
        ];
    };

    wayland.windowManager.hyprland = mkIf (config.host.home.feature.gui.displayServer == "wayland" && config.host.home.feature.gui.windowManager == "hyprland" && config.host.home.feature.gui.enable) {
      settings = {
        bindl = [
          ",XF86AudioPlay, exec, ${config.host.home.feature.uwsm.prefix}playerctl play-pause"
          ",XF86AudioPrev, exec, ${config.host.home.feature.uwsm.prefix}playerctl previous"
          ",XF86AudioNext, exec, ${config.host.home.feature.uwsm.prefix}playerctl next"
          ",XF86AudioMedia, exec, ${config.host.home.feature.uwsm.prefix}playerctl play-pause"
          ",XF86AudioStop, exec, ${config.host.home.feature.uwsm.prefix}playerctl stop"
        ];
      };
    };
  };
}
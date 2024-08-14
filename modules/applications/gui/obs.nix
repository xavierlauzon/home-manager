{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.obs;
in
  with lib;
{
  options = {
    host.home.applications.obs = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Open source screen recording & broadcasting software";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          obs-studio
          obs-studio-plugins.wlrobs
          obs-studio-plugins.obs-vaapi
          obs-studio-plugins.obs-vkcapture
          obs-studio-plugins.obs-gstreamer
          obs-studio-plugins.obs-pipewire-audio-capture

        ];
    };
  };
}

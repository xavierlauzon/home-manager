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
          (wrapOBS {
            plugins = with obs-studio-plugins; [
              wlrobs
              obs-vaapi
              obs-vkcapture
              obs-gstreamer
              obs-pipewire-audio-capture
            ];
          })
          v4l-utils
        ];

    };
  };
}

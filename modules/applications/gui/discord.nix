{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.discord;
  krisp-patcher =
    pkgs.writers.writePython3Bin "krisp-patcher"
      {
        libraries = with pkgs.python3Packages; [
          capstone
          pyelftools
        ];
        flakeIgnore = [
          "E501" # line too long (82 > 79 characters)
          "F403" # 'from module import *' used; unable to detect undefined names
          "F405" # name may be undefined, or defined from star imports: module
        ];
      }
      (
        builtins.readFile (
          pkgs.fetchurl {
            url = "https://pastebin.com/raw/8tQDsMVd";
            sha256 = "sha256-IdXv0MfRG1/1pAAwHLS2+1NESFEz2uXrbSdvU9OvdJ8=";
          }
        )
      );
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
          unstable.vesktop
          unstable.discord
          unstable.legcord
          stable.equicord
        ];
    };

    wayland.windowManager.hyprland = mkIf (config.host.home.feature.gui.displayServer == "wayland" && config.host.home.feature.gui.windowManager == "hyprland" && config.host.home.feature.gui.enable) {
      settings = {
        exec-once = [
          "vesktop"
        ];
      };
    };
  };
}

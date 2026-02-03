{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.prismlauncher;
in
  with lib;
{
  options = {
    host.home.applications.prismlauncher = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Open Source Modded Minecraft Launcher";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          (prismlauncher.override {
            jdks = [ jdk8 jdk17 jdk21 jdk25 ];
          })
        ];
    };
  };
}

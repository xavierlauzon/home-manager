{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.satisfactorymodmanager;
in
  with lib;
{
  options = {
    host.home.applications.satisfactorymodmanager = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Mod Manager for Satisfactory";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          satisfactorymodmanager
        ];
    };
  };
}

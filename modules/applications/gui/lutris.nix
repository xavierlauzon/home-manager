{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.lutris;
in
  with lib;
{
  options = {
    host.home.applications.lutris = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Open source video game launcher";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          lutris
        ];
    };
  };
}

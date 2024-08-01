{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.gparted;
in
  with lib;
{
  options = {
    host.home.applications.gparted = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Graphical Partition Manager";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          gparted
        ];
    };
  };
}

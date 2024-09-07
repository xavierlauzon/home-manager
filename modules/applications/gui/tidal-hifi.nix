{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.tidl-hifi;
in
  with lib;
{
  options = {
    host.home.applications.tidal-hifi = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "HiFi music streaming service";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          tidal-hifi
        ];
    };
  };
}

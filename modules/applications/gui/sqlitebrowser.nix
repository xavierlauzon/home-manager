{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.sqlite-browser;
in
  with lib;
{
  options = {
    host.home.applications.sqlite-browser = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Database Manager";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          sqlitebrowser
        ];
    };
  };
}

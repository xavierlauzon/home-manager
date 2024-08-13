{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.fastfetch;
in
  with lib;
{
  options = {
    host.home.applications.fastfetch = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "System Information Tool";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          fastfetch
        ];
    };
  };
}

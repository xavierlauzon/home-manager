{config, inputs, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.komodo;
in
  with lib;
{
  options = {
    host.home.applications.komodo = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Komodo CLI (km) for builds, deployments, and server management";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          unstable.komodo
        ];
    };
  };
}

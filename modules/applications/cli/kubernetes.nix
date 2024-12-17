{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.kubernetes;
in
  with lib;
{
  options = {
    host.home.applications.kubernetes = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Container orchestration platform controls";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          kubernetes-helm
          kubectl
        ];
    };
  };
}

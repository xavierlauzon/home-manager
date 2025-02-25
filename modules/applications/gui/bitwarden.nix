{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.bitwarden;
in
  with lib;
{
  options = {
    host.home.applications.bitwarden = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Password Manager";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          bitwarden-desktop
          bitwarden-cli
        ];
    };
  };
}

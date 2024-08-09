{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.discord;
in
  with lib;
{
  options = {
    host.home.applications.discord = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Discord, VoIP & IM";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          vesktop
        ];
    };
  };
}

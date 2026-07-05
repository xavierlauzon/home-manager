{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.opencode;
in
  with lib;
{
  options = {
    host.home.applications.opencode = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "AI coding agent";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          opencode
          opencode-desktop
        ];
    };
  };
}

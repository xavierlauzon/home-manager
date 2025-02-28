{config, lib, ...}:

let
  cfg = config.host.home.applications.ssh;
in
  with lib;
{
  options = {
    host.home.applications.ssh = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Secure Shell Client";
      };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      ssh = {
        enable = true;
      };
    };
  };
}

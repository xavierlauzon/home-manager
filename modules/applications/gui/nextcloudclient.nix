{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.nextcloud-client;
in
  with lib;
{
  options = {
    host.home.applications.nextcloud-client = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "File synchronization";
      };
      service.enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Auto start on user session start";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          nextcloud-client
        ];
    };

    systemd.user.services.nextcloud-client = mkIf cfg.service.enable {
      Unit = {
        Description = "Nextcloud client";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "exec";
        ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud --background";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

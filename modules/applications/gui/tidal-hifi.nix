{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.tidal-hifi;
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
          unstable.tidal-hifi
        ];
    };

    systemd.user.services.tidal-hifi = mkIf cfg.service.enable {
      Unit = {
        Description = "Tidal HiFi player";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "exec";
        ExecStart = "${pkgs.unstable.tidal-hifi}/bin/tidal-hifi";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

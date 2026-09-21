{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.ferdium;
in
  with lib;
{
  options = {
    host.home.applications.ferdium = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Multi Messaging tool";
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
          unstable.ferdium
        ];
    };

    systemd.user.services.ferdium = mkIf cfg.service.enable {
      Unit = {
        Description = "Ferdium messaging client";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "exec";
        ExecStart = "${pkgs.unstable.ferdium}/bin/ferdium";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

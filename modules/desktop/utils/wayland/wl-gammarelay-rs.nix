{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.wl-gammarelay-rs;
in
  with lib;
{
  options = {
    host.home.applications.wl-gammarelay-rs = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Wayland Monitor Gamma Adjustment";
      };
      service.enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Auto start on user session start";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          wl-gammarelay-rs
        ];
    };

    systemd.user.services.wl-gammarelay-rs = mkIf cfg.service.enable {
      Unit = {
        Description = "A simple program that provides DBus interface to control display temperature and brightness under wayland without flickering.";
        Documentation = "https://github.com/MaxVerevkin/wl-gammarelay-rs";
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs run";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
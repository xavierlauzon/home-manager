{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.obsidian;
in
  with lib;
{
  options = {
    host.home.applications.obsidian = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Note taking tool";
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
          obsidian
        ];
    };

    nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
    ];

    systemd.user.services.obsidian = mkIf cfg.service.enable {
      Unit = {
        Description = "Obsidian note taking app";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "exec";
        ExecStart = "${pkgs.obsidian}/bin/obsidian";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

  };
}

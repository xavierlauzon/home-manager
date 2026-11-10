{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.home.applications.super-productivity;
in
  with lib; {
    options = {
      host.home.applications.super-productivity = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Super Productivity - To Do List / Time Tracker with Jira integration";
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
        packages = with pkgs; [
          superproductivity
        ];
      };

      systemd.user.services.superproductivity = mkIf cfg.service.enable {
        Unit = {
          Description = "Super Productivity time tracker";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
          ConditionEnvironment = ["WAYLAND_DISPLAY"];
        };

        Service = {
          Type = "exec";
          ExecStart = "${pkgs.superproductivity}/bin/superproductivity";
          Restart = "on-failure";
          Slice = "app-graphical.slice";
        };

        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    };
  }

{ config, lib, pkgs, ... }:
let
  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;
in
with lib;
{
  options = {
    host.home.applications.steam = {
      service.enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Auto start Steam on user session start";
      };
    };
  };

  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland") {
    systemd.user.services.steam = mkIf config.host.home.applications.steam.service.enable {
      Unit = {
        Description = "Steam game client";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "exec";
        ExecStart = "${pkgs.bash}/bin/bash -lc 'steam -silent'";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

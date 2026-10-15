{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.theme-panel;
  srcDir =
    if cfg.srcDir != null
    then cfg.srcDir
    else "${config.home.homeDirectory}/src/desktop-theme-panel";
in
  with lib;
{
  options = {
    host.home.applications.theme-panel = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Desktop theme control panel (Hyprland + DankMaterialShell).";
      };
      service.enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Auto-start the panel server (http://localhost:8742) on user session start.";
      };
      srcDir = mkOption {
        default = null;
        type = with types; nullOr str;
        description = "Path to the desktop-theme-panel checkout. Defaults to ~/src/desktop-theme-panel.";
      };
    };
  };

  config = mkIf cfg.enable {
    # The panel is a zero-dependency Node server (node: built-ins only); the
    # store nodejs runs it. It shells out to dms/hyprctl/matugen at request time,
    # so PATH must include the user profile (where those land) plus the system
    # dirs. HYPRLAND_INSTANCE_SIGNATURE is auto-detected from XDG_RUNTIME_DIR.
    systemd.user.services.theme-panel = mkIf cfg.service.enable {
      Unit = {
        Description = "Desktop theme control panel (http://localhost:8742)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.nodejs_22}/bin/node ${srcDir}/server/server.mjs";
        WorkingDirectory = "${srcDir}";
        Environment = [
          "PATH=${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin:/run/wrappers/bin:/usr/bin:/bin"
        ];
        Restart = "on-failure";
        RestartSec = 2;
        Slice = "app-graphical.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

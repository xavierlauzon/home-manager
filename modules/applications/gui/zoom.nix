{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.zoom;
in
  with lib;
{
  options = {
    host.home.applications.zoom = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Video Conferencing";
      };
      defaultApplication = {
        enable = mkOption {
          description = "MIME default application configuration";
          type = with types; bool;
          default = false;
        };
        mimeTypes = mkOption {
          description = "MIME types to be the default application for";
          type = types.listOf types.str;
          default = [
            "x-scheme-handler/zoomtg"
          ];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          unstable.zoom-us
        ];
    };

   wayland.windowManager.hyprland = {
      settings = {
        windowrule = [
          "size 360 690, match:title ^Zoom - Licensed Account$, match:class ^(Zoom)$"
          "float on, match:title ^Zoom - Licensed Account$"
          "no_anim on, match:class ^(Zoom)$"
          "no_dim on, match:class ^(Zoom)$"
          "no_blur on, match:class ^(Zoom)$"
          "float on, match:title ^as_toolbar$, match:class ^(Zoom)$"
          "decorate off, match:title ^as_toolbar$, match:class ^(Zoom)$"
          "no_shadow on, match:title ^as_toolbar$, match:class ^(Zoom)$"
          "no_blur on, match:title ^as_toolbar$, match:class ^(Zoom)$"
          "min_size 1 1, match:title ^(Zoom Workplace.*)$, match:class ^(Zoom Workplace)$"
          "min_size 1 1, match:title ^(menu window)$, match:class ^(Zoom Workplace)$"
          "min_size 1 1, match:title ^(meeting bottombar popup)$, match:class ^(Zoom Workplace)$"
          "min_size 1 1, match:title ^(Zoom Workplace.*)$, match:class ^(zoom)$"
          "min_size 1 1, match:title ^(menu window)$, match:class ^(zoom)$"
          "min_size 1 1, match:title ^(meeting bottombar popup)$, match:class ^(zoom)$"
          "move onscreen cursor, match:title ^(Zoom Workplace)$, match:class ^(zoom)$"
          "move onscreen cursor, match:title ^(menu window)$, match:class ^(zoom)$"
          "move onscreen cursor, match:title ^(meeting bottombar popup)$, match:class ^(zoom)$"
          "move onscreen cursor, match:title ^(Zoom Workplace)$, match:class ^(Zoom Workplace)$"
          "move onscreen cursor, match:title ^(menu window)$, match:class ^(Zoom Workplace)$"
          "move onscreen cursor, match:title ^(meeting bottombar popup)$, match:class ^(Zoom Workplace)$"
          "stay_focused on, match:title ^(menu window)$, match:class ^(Zoom Workplace)$"
          "stay_focused on, match:title ^(meeting bottombar popup)$, match:class ^(Zoom Workplace)$"
          "stay_focused on, match:title ^(menu window)$, match:class ^(zoom)$"
          "stay_focused on, match:title ^(meeting bottombar popup)$, match:class ^(zoom)$"
        ];
      };
    };

    xdg.mimeApps.defaultApplications = mkIf cfg.defaultApplication.enable (
      lib.genAttrs cfg.defaultApplication.mimeTypes (_: "us.zoom.Zoom.desktop")
    );
  };
}
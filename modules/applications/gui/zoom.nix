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
        window_rule = [
          { match = { title = "^Zoom - Licensed Account$"; class = "^(Zoom)$"; }; size = "360x690"; }
          { match = { title = "^Zoom - Licensed Account$"; }; float = true; }
          { match = { class = "^(Zoom)$"; }; no_anim = true; }
          { match = { class = "^(Zoom)$"; }; no_dim = true; }
          { match = { class = "^(Zoom)$"; }; no_blur = true; }
          { match = { title = "^as_toolbar$"; class = "^(Zoom)$"; }; float = true; }
          { match = { title = "^as_toolbar$"; class = "^(Zoom)$"; }; decorate = false; }
          { match = { title = "^as_toolbar$"; class = "^(Zoom)$"; }; no_shadow = true; }
          { match = { title = "^as_toolbar$"; class = "^(Zoom)$"; }; no_blur = true; }
          { match = { title = "^(Zoom Workplace.*)$"; class = "^(Zoom Workplace)$"; }; min_size = "1x1"; }
          { match = { title = "^(menu window)$"; class = "^(Zoom Workplace)$"; }; min_size = "1x1"; }
          { match = { title = "^(meeting bottombar popup)$"; class = "^(Zoom Workplace)$"; }; min_size = "1x1"; }
          { match = { title = "^(Zoom Workplace.*)$"; class = "^(zoom)$"; }; min_size = "1x1"; }
          { match = { title = "^(menu window)$"; class = "^(zoom)$"; }; min_size = "1x1"; }
          { match = { title = "^(meeting bottombar popup)$"; class = "^(zoom)$"; }; min_size = "1x1"; }
          { match = { title = "^(Zoom Workplace)$"; class = "^(zoom)$"; }; move = "onscreen cursor"; }
          { match = { title = "^(menu window)$"; class = "^(zoom)$"; }; move = "onscreen cursor"; }
          { match = { title = "^(meeting bottombar popup)$"; class = "^(zoom)$"; }; move = "onscreen cursor"; }
          { match = { title = "^(Zoom Workplace)$"; class = "^(Zoom Workplace)$"; }; move = "onscreen cursor"; }
          { match = { title = "^(menu window)$"; class = "^(Zoom Workplace)$"; }; move = "onscreen cursor"; }
          { match = { title = "^(meeting bottombar popup)$"; class = "^(Zoom Workplace)$"; }; move = "onscreen cursor"; }
          { match = { title = "^(menu window)$"; class = "^(Zoom Workplace)$"; }; stay_focused = true; }
          { match = { title = "^(meeting bottombar popup)$"; class = "^(Zoom Workplace)$"; }; stay_focused = true; }
          { match = { title = "^(menu window)$"; class = "^(zoom)$"; }; stay_focused = true; }
          { match = { title = "^(meeting bottombar popup)$"; class = "^(zoom)$"; }; stay_focused = true; }
        ];
      };
    };

    xdg.mimeApps.defaultApplications = mkIf cfg.defaultApplication.enable (
      lib.genAttrs cfg.defaultApplication.mimeTypes (_: "us.zoom.Zoom.desktop")
    );
  };
}
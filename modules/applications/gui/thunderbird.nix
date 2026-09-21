{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.thunderbird;
in
  with lib;
{
  options = {
    host.home.applications.thunderbird = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Mail, Calendar, and IM";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          unstable.thunderbird
        ];
    };

    programs = {
      thunderbird = {
        enable = false;
        ## TODO - This needs conversion
      };
    };

    wayland.windowManager.hyprland = mkIf (config.host.home.feature.gui.displayServer == "wayland" && config.host.home.feature.gui.windowManager == "hyprland" && config.host.home.feature.gui.enable) {
      settings = {
        window_rule = [
          { match = { class = "^(thunderbird)$"; }; workspace = "1"; }
          { match = { class = "^(thunderbird)$"; title = "^(.*)(Reminder)(.*)$"; }; float = true; }
          { match = { class = "^(thunderbird)$"; title = "^About(.*)$"; }; float = true; }
          { match = { class = "^(thunderbird)$"; title = "^(Check Spelling)$"; }; float = true; }
          { match = { class = "^(thunderbird)$"; title = "^(Check Spelling)$"; }; size = "525x335"; }
        ];
      };
    };
  };
}

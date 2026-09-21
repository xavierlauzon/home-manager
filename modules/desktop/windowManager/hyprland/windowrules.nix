{ config, lib, ... }:
let
  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;
in
with lib;
{
  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland") {
    wayland.windowManager.hyprland = {
      settings = {
        ## See more in modules/applications/* and modules/desktop/utils/*
        window_rule = [
          # XDG-Portal-GTK File Picker annoyances
          { match = { title = "^(Open Files)$"; }; dim_around = true; }
          { match = { title = "^(Open Files)$"; }; float = true; }
          { match = { title = "^(Open Files)$"; }; size = ["1290" "800"]; }

          # Generics
          { match = { class = "^(xdg-desktop-portal-hyprland)$"; }; float = true; }
          { match = { class = "^()$"; title = "^(File Operation Progress)$"; }; float = true; }
          { match = { class = ".*"; }; suppress_event = "maximize"; }

          # Position
          { match = { class = "^(Viewnior)$"; }; float = true; }
          { match = { class = "^(confirm)$"; }; float = true; }
          { match = { class = "^(confirmreset)$"; }; float = true; }
          { match = { class = "^(dialog)$"; }; float = true; }
          { match = { class = "^(download)$"; }; float = true; }
          { match = { class = "^(error)$"; }; float = true; }
          { match = { class = "^(file_progress)$"; }; float = true; }
          { match = { class = "^(notification)$"; }; float = true; }
          { match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$"; }; float = true; }
          { match = { class = "^(pavucontrol)$"; }; float = true; }
          { match = { title = "^(Confirm to replace files)"; }; float = true; }
          { match = { title = "^(DevTools)$"; }; float = true; }
          { match = { title = "^(File Operation Progress)"; }; float = true; }
          { match = { title = "^(Media viewer)$"; }; float = true; }
          { match = { title = "^(Open File)$"; }; float = true; }
          { match = { title = "^(Picture-in-Picture)$"; }; float = true; }
          { match = { title = "^(Volume Control)$"; }; float = true; }
          { match = { title = "^(branchdialog)$"; }; float = true; }

          # Size
          { match = { class = "^(download)$"; }; size = ["800" "600"]; }
          { match = { title = "^(Open File)$"; }; size = ["800" "600"]; }
          { match = { title = "^(Save File)$"; }; size = ["800" "600"]; }
          { match = { title = "^(Volume Control)$"; }; size = ["800" "600"]; }
        ];
      };
    };
  };
}

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
        windowrule = [
          # IDLE inhibit while watching videos
          #"idle_inhibit focus, match:class (mpv|.+exe)"
          #"idle_inhibit focus, match:class firefox, match:title .*YouTube.*"
          #"idle_inhibit fullscreen, match:class firefox"

          # XDG-Portal-GTK File Picker annoyances
          "dim_around on, match:title ^(Open Files)$"
          "float on, match:title ^(Open Files)$"
          "size 1290 800, match:title ^(Open Files)$"

          # Generics
          "float on, match:class ^(xdg-desktop-portal-hyprland)$"
          "float on, match:class ^()$, match:title ^(File Operation Progress)$"
          "suppress_event maximize, match:class .*"

          # Position
          "float on, match:class ^(Viewnior)$"
          "float on, match:class ^(confirm)$"
          "float on, match:class ^(confirmreset)$"
          "float on, match:class ^(dialog)$"
          "float on, match:class ^(download)$"
          "float on, match:class ^(error)$"
          "float on, match:class ^(file_progress)$"
          "float on, match:class ^(notification)$"
          "float on, match:class ^(org.kde.polkit-kde-authentication-agent-1)$"
          "float on, match:class ^(pavucontrol)$"
          "float on, match:title ^(Confirm to replace files)"
          "float on, match:title ^(DevTools)$"
          "float on, match:title ^(File Operation Progress)"
          "float on, match:title ^(Media viewer)$"
          "float on, match:title ^(Open File)$"
          "float on, match:title ^(Picture-in-Picture)$"
          "float on, match:title ^(Volume Control)$"
          "float on, match:title ^(branchdialog)$"

          # Size
          "size 800 600, match:class ^(download)$"
          "size 800 600, match:title ^(Open File)$"
          "size 800 600, match:title ^(Save File)$"
          "size 800 600, match:title ^(Volume Control)$"
        ];
      };
    };
  };
}

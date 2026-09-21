{ config, inputs, lib, pkgs, ... }:
let
  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;
in

with lib;
{
  imports = [
#    inputs.hyprland.homeManagerModules.default
    ./binds.nix
    ./decorations.nix
    ./input.nix
    ./settings.nix
    ./startup.nix
    ./windowrules.nix
    ./displays.nix
  ];

  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland") {
    host = {
      home = {
        applications = {
          dms.enable = mkDefault true;
          hyprcursor.enable = mkDefault true;
          hyprdim.enable = mkDefault true;

          hyprlock.enable = true;

          hyprpicker.enable = mkDefault true;

          hyprkeys.enable = mkDefault false;
          playerctl.enable = mkDefault true;
          satty.enable = mkDefault true;



          rofi.enable = mkDefault false;
          hypridle = {
            enable = mkDefault true;
            service.enable = mkDefault false;
          };
          hyprpaper = {
            enable = mkDefault false;
            service.enable = mkDefault false;
          };
          hyprpolkitagent = {
            enable = mkDefault true;
            service.enable = mkDefault false;
          };
          hyprsunset = {
            enable = mkDefault true;
            service.enable = mkDefault false;
          };
          sway-notification-center = {
            enable = mkDefault false;
            service.enable = mkDefault false;
          };
          swayosd = {
            enable = mkDefault true;
            service.enable = mkDefault false;
          };
          waybar = {
            enable = mkDefault false;
            service.enable = mkDefault false;
          };

        };
        feature = {
          uwsm.enable = mkDefault true;
        };
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
      settings = {
        env = mkIf (! config.host.home.feature.uwsm.enable) [
          { _args = [ "XDG_CURRENT_DESKTOP" "Hyprland" ]; }
          { _args = [ "XDG_SESSION_TYPE" "wayland" ]; }
          { _args = [ "XDG_SESSION_DEKSTOP" "Hyprland" ]; }
          { _args = [ "QT_AUTO_SCREEN_SCALE_FACTOR" "1" ]; }
          { _args = [ "QT_QPA_PLATFORM" "wayland;xcb" ]; }
          { _args = [ "QT_WAYLAND_DISABLE_WINDOWDECORATION" "1" ]; }
          { _args = [ "QT_QPA_PLATFORMTHEME" "qt6ct" ]; }
          { _args = [ "MOZ_ENABLE_WAYLAND" "1" ]; }
          { _args = [ "GDK_BACKEND" "wayland,x11,*" ]; }
          { _args = [ "SDL_VIDEODRIVER" "wayland" ]; }
          { _args = [ "CLUTTER_BACKEND" "wayland" ]; }
          { _args = [ "ELECTRON_OZONE_PLATFORM_HINT" "auto" ]; }
          { _args = [ "NIXOS_OZONE_WL" "1" ]; }
        ];
      };
      systemd.enable = mkDefault false;
      xwayland.enable = mkDefault true;
    };

    xdg = {
      configFile."uwsm/env".text = mkIf config.host.home.feature.uwsm.enable
        ''
          export CLUTTER_BACKEND="wayland"
          export GDK_BACKEND="wayland,x11,*"
          export MOZ_ENABLE_WAYLAND=1
          export QT_AUTO_SCREEN_SCALE_FACTOR=1
          export QT_QPA_PLATFORM="wayland;xcb"
          export QT_QPA_PLATFORMTHEME=qt6ct
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          export SDL_VIDEODRIVER="wayland"
          export NIXOS_OZONE_WL=1
          export ELECTRON_OZONE_PLATFORM_HINT="wayland"
          export ELECTRON_ENABLE_WAYLAND="1"
          export WLR_RENDERER="vulkan"
        '';
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        configPackages = [ pkgs.unstable.xdg-desktop-portal-hyprland ];
        config.common = {
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
        };
        extraPortals = [
          pkgs.unstable.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };
  };
}

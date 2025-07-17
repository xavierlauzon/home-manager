{ config, inputs, lib, pkgs, ... }:
let
  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;

  gameMode = pkgs.writeShellScriptBin "gamemode" ''
    HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==2{print $2}')
    if [ "$HYPRGAMEMODE" = 1 ] ; then
      hyprctl --batch "\
          keyword animations:enabled 0;\
          keyword decoration:blur 0;\
          keyword general:gaps_in 0;\
          keyword general:gaps_out 0;\
          keyword general:border_size 1;\
          keyword decoration:rounding 0"
      exit
    else
      hyprctl --batch "\
          keyword animations:enabled 1;\
          keyword decoration:blur 1;\
          keyword general:gaps_in 1;\
          keyword general:gaps_out 1;\
          keyword general:border_size 1;\
          keyword decoration:rounding 1"
    fi
    hyprctl reload
  '';
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
    home = {
      packages = with pkgs;
        [
          gameMode
          #hyprland-share-picker     # If this works outside of Hyprland modularize
        ];
    };

    host = {
      home = {
        applications = {
          hyprcursor.enable = mkDefault true;
          hyprdim.enable = mkDefault true;
          hypridle = {
            enable = mkDefault true;
            service.enable = mkDefault true;
          };
          hyprlock.enable = true;
          hyprpaper = {
            enable = mkDefault false;
            service.enable = mkDefault false;
          };
          hyprpicker.enable = mkDefault true;
          hyprpolkitagent = {
            enable = mkDefault true;
            service.enable = mkDefault true;
          };
          hyprsunset = {
            enable = mkDefault true;
            service.enable = mkDefault true;
          };
          hyprkeys.enable = mkDefault true;
          playerctl.enable = mkDefault true;
          satty.enable = mkDefault true;
          rofi.enable = mkDefault true;
          sway-notification-center = {
            enable = mkDefault true;
            service.enable = mkDefault true;
          };
          swayosd = {
            enable = mkDefault true;
            service.enable = mkDefault true;
          };
          waybar = {
            enable = mkDefault true;
            service.enable = mkDefault true;
          };
        };
        feature = {
          uwsm.enable = mkDefault true;
        };
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      settings = {
        env = mkIf (! config.host.home.feature.uwsm.enable) [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DEKSTOP,Hyprland"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "QT_QPA_PLATFORMTHEME,qt6ct"
          "MOZ_ENABLE_WAYLAND,1"
          "GDK_BACKEND,wayland,x11,*"
          "SDL_VIDEODRIVER,wayland"
          "CLUTTER_BACKEND,wayland"
          "XDG_SESSION_TYPE,wayland"
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
          "NIXOS_OZONE_WL,1"
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
        configPackages = [ pkgs.xdg-desktop-portal-hyprland ];
        config.common = {
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
        };
        extraPortals = [
          pkgs.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };
  };
}

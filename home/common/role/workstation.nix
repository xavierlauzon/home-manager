{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
  ];

  host = {
    home = {
      applications = {
        act.enable = mkDefault false;
        android-tools.enable = mkDefault true;
        ark = {
          enable = mkDefault false;
          defaultApplication.enable = mkDefault true;
        };
        bleachbit.enable = mkDefault true;
        blueman.enable = mkDefault true;
        calibre = {
          enable = mkDefault true;
          defaultApplication.enable = mkDefault true;
        };
        chromium.enable = mkDefault true;
        docker-compose.enable = mkDefault true;
        discord.enable = mkDefault true;
        drawio = {
          enable = mkDefault true;
          defaultApplication.enable = mkDefault true;
        };
        eog = {
          enable = mkDefault true;
          defaultApplication.enable = mkDefault true;
        };
        ferdium.enable = mkDefault true;
        firefox.enable = mkDefault true;
        floorp = {
          enable = mkDefault true;
          defaultApplication.enable = mkDefault true;
        };
        geeqie.enable = mkDefault true;
        git.enable = mkDefault true;
        gnome-system-monitor.enable = mkDefault true;
        gnome-software.enable = mkDefault true;
        github-client.enable = mkDefault true;
        gparted.enable = mkDefault true;
        kitty.enable = mkDefault true;
        kubernetes.enable = mkDefault true;
        lazygit.enable = mkDefault true;
        libreoffice.enable = mkDefault true;
        master-pdf-editor.enable = mkDefault true;
        mate-calc.enable = mkDefault true;
        nemo.enable = mkDefault true;
        nextcloud-client.enable = mkDefault true;
        nix-development_tools.enable = true;
        nmap.enable = mkDefault true;
        obsidian.enable = mkDefault true;
        opensnitch-ui.enable = mkDefault true;
        prismlauncher.enable = mkDefault true;
        pulsemixer.enable = mkDefault true;
        remmina = {
          enable = mkDefault true;
          defaultApplication.enable = mkDefault true;
        };
        seahorse.enable = mkDefault true;
        smartgit.enable = mkDefault true;
        tea.enable = mkDefault true;
        thunderbird.enable = mkDefault true;
        tidal-hifi.enable = mkDefault true;
        veracrypt.enable = mkDefault true;
        virt-manager.enable = mkDefault true;
        visual-studio-code = {
          enable = mkDefault true;
          defaultApplication.enable = mkDefault true;
        };
        vlc = {
          enable = mkDefault true;
          defaultApplication.enable = mkDefault true;
        };
        yq.enable = mkDefault true;
        zoom.enable = mkDefault true;
        zathura = {
          enable = mkDefault true;
          defaultApplication.enable = mkDefault true;
        };
      };
      feature = {
        fonts.enable = mkDefault true;
        mime.defaults.enable = mkDefault true;
        theming.enable = mkDefault true;
        emulation = {
          windows.enable = true;
        };
        gui = {
          enable = true;
          displayServer = "wayland";
          windowManager = "hyprland";
        };
      };
      service = {
        vscode-server.enable = mkDefault true;
      };
    };
  };

  xdg = {
    mimeApps = {
      enable = mkDefault true;
    };
  };
}


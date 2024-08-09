{ config, lib, pkgs, specialArgs, ...}:
let
  inherit (specialArgs) displays display_center display_left display_right role;
in
with lib;
{
  host = {
    home = {
      applications = {
        act.enable = mkDefault false;
        avidemux.enable = true;
        cura.enable = false;
        czkawka.enable = mkDefault true;
        github-client.enable = true;
        gnome-software.enable = true;
        hadolint.enable = true;
        lazygit.enable = true;
        mp3gain.enable = mkDefault true;
        nix-development_tools.enable = true;
        nmap.enable = mkDefault true;
        obsidian.enable = true;
        opensnitch-ui.enable = true;
        shellcheck.enable = true;
        shfmt.enable = true;
        smartgit.enable = false;
        ssh = {
          enable = true;
          ignore = {
            "192.168.1.0/24" = true;
            "192.168.4.0/24" = true;
          };
        };
        szyszka.enable = true;
        thunderbird.enable = mkDefault true;
        veracrypt.enable = true;
        virt-manager.enable = mkDefault true;
        visual-studio-code = {
          enable = mkDefault true;
          defaultApplication.enable = mkDefault true;
        };
        xmlstarlet.enable = true;
        yq.enable = true;
        xdg-ninja.enable = mkDefault true;
        yt-dlp.enable = mkDefault true;
        zathura = {
          enable = mkDefault true;
          defaultApplication.enable = mkDefault true;
        };
        prismlauncher.enable = true;
        discord.enable = true;
      };
      feature = {
        emulation = {
          windows.enable = true;
        };
        gui = {
          enable = true;
          displayServer = "wayland";
          windowManager = "hyprland";
        };
      };
#      user = {
#        xavier = {
#          secrets = {
#            github = {
#              xl.enable = false;
#            };
#            ssh = {
#              sd.enable = true;
#              xl.enable = true;
#            };
#          };
#        };
#      };
    };
  };

  services.autorandr.enable = false;
}

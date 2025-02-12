{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
  ];

  host = {
    home = {
      applications = {
        docker-compose.enable = mkDefault true;
        git.enable = mkDefault true;
        lazygit.enable = mkDefault true;
        tea.enable = mkDefault true;
        kubernetes.enable = mkDefault true;
      };
      feature = {
        theming.enable = mkDefault false;
      };
      service = {
      };
    };
  };
  colorscheme = inputs.nix-colors.colorSchemes.dracula;
}

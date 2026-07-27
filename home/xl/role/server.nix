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
      };
      feature = {
      };
      services = {
      };
    };
  };
  colorscheme = inputs.nix-colors.colorSchemes.dracula; # TODO make less messy
}
{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
  ];

  host = {
    home = {
      applications = {
      };
      feature = {
      };
#      services = {
#        vscode-server.enable = mkDefault true;
#      };
    };
  };
}
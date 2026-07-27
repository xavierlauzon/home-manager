{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
  ];

  host = {
    home = {
      applications = {
        opencode.enable = mkDefault true;
      };
      feature = {
      };
      service = {
      };
    };
  };
}
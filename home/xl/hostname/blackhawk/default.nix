{ config, lib, pkgs, specialArgs, ...}:
let
  inherit (specialArgs) displays display_center display_left display_right role;
in
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
      service = {
      };
    };
  };
}
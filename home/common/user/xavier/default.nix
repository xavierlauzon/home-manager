{ config, inputs, lib, pkgs, specialArgs, ... }:

with lib;
{
  imports = [
    ./secrets
  ];

  config = {
    programs = {
      git = {
        username = "Xavier Lauzon"
      };
    };
  };
}

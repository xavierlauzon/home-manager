{ config, lib, pkgs, specialArgs, ...}:
with lib;
{
  host = {
    home = {
      user = {
        xavier = {
          secrets = {
            komodo.enable = true;
          };
        };
      };
    };
  };
}

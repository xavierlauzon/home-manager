{ config, lib, pkgs, specialArgs, ...}:
with lib;
{
  host = {
    home = {
      user = {
        sam = {
          secrets = {
            ssh = {
              xl.enable = true;
            };
          };
        };
      };
    };
  };
}

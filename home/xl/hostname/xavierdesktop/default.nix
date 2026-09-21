{ config, lib, pkgs, specialArgs, ...}:
with lib;
{
  host = {
    home = {
      applications = {
      };
      feature = {
        vkbasalt.enable = true;
      };
      user = {
        xavier = {
          secrets = {
#            github = {
#              xl.enable = false;
#            };
            ssh = {
              sd.enable = true;
              xl.enable = true;
            };
          };
        };
      };
    };
  };
}

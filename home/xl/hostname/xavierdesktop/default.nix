{ config, lib, pkgs, specialArgs, ...}:
let
  inherit (specialArgs) displays display_center display_left display_right role;
in
with lib;
{
  host = {
    home = {
      applications = {
        ssh = {
          enable = true;
          };
        };
      };
      feature = {
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

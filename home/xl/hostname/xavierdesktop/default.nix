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
          ignore = {
            "192.168.1.0/24" = true;
            "192.168.4.0/24" = true;
          };
        };
      };
      feature = {
      };
#      user = {
#        xavier = {
#          secrets = {
#            github = {
#              xl.enable = false;
#            };
#            ssh = {
#              sd.enable = true;
#              xl.enable = true;
#            };
#          };
#        };
#      };
    };
  };
}

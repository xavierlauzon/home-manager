{ config, lib, pkgs, specialArgs, ...}:
with lib;
{
  host = {
    home = {
      user = {
        sam = {
          secrets = {
            komodo = {
              mcpEnv.enable = true;
            };
            ssh = {
              xl.enable = true;
              sampc.enable = true;
              lumae.enable = true;
            };
          };
        };
      };
    };
  };
}

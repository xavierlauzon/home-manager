{ config, lib, pkgs, specialArgs, ...}:
with lib;
{
  host = {
    home = {
      applications = {
        # Personal theme control panel (lives in ~/src/desktop-theme-panel).
        # Scoped to sam@blackhawk so it doesn't enable on other hosts/users.
        theme-panel.enable = true;
      };
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

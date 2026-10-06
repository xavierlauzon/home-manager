{config, inputs, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.herdr;
in
  with lib;
{
  options = {
    host.home.applications.herdr = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Terminal workspace manager / runtime for AI coding agents";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        unstable.herdr
      ];

    xdg.configFile."herdr/config.toml".text = ''
      onboarding = false

      [ui.toast]
      delivery = "system"

      [ui]
      status_indicators = "symbols"

      [theme]
      name = "gruvbox"
      auto_switch = false
    '';
  };
}

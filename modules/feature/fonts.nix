{config, lib, pkgs, ...}:

let
  cfg = config.host.home.feature.fonts;
in
  with lib;
{
  options = {
    host.home.feature.fonts = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable fonts";
      };
    };
  };

  config = mkIf cfg.enable {
    fonts = {
      fontconfig = {
        enable = true ;
      };
    };

    home.packages = with pkgs; [
      caladea
      cantarell-fonts
      carlito
      courier-prime
      dejavu_fonts
      font-awesome
      gelasio
      liberation_ttf
      material-design-icons
      merriweather
      noto-fonts
      noto-fonts-color-emoji
      open-sans
      roboto
      ubuntu-classic
      weather-icons
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.open-dyslexic
    ];
  };
}

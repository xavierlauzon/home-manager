{config, inputs, lib, pkgs, specialArgs, ...}:

let
  inherit (specialArgs) role username;
  cfg = config.host.home.feature.theming;
in
  with lib;
{
  imports = [
    inputs.nix-colors.homeManagerModule
    inputs.catppuccin.homeModules.catppuccin
  ];

  options = {
    host.home.feature.theming = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable theming";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      colorscheme = inputs.nix-colors.colorSchemes.dracula;
      catppuccin = {
        enable = true;
        autoEnable = true;
        cache.enable = true;
        cursors = {
          enable = true;
          flavor = "mocha";
        };
        hyprland.enable = false;
        kitty.enable = true;
        floorp.enable = true;
        anki.enable = false;
      };
    })
    (mkIf (!cfg.enable) {
      catppuccin = {
        enable = false;
        autoEnable = false;
      };
    })
  ];
}
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

  config = mkIf cfg.enable {
    colorscheme = inputs.nix-colors.colorSchemes.dracula;
    catppuccin = {
      flavor = "mocha";
      cursors = {
        enable = true;
        flavor = "mocha";
      };
      kitty.enable = true;
      floorp.enable = true;
      anki.enable = false;
    };
  };
}
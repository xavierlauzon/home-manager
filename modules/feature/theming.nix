{config, inputs, lib, pkgs, specialArgs, ...}:

let
  inherit (specialArgs) role username;
  cfg = config.host.home.feature.theming;
in
  with lib;
{
  imports = [
    inputs.nix-colors.homeManagerModule
  ];

  options = {
    host.home.feature.theming = {
      enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Enable theming";
      };
    };
  };

  config = mkIf cfg.enable {
    colorscheme = inputs.nix-colors.colorSchemes.dracula;
    catppuccin = {
      flavor = "mocha";
      pointerCursor = {
        enable = true;
        flavor = "mocha";
      };

    };
    programs = {
        kitty.catppuccin.enable = true;
    };
  };
}

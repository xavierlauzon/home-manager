{
  description = "Xavier's Home Manager configuration";

  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    comma.url = "github:nix-community/comma";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    catppuccin-vsc.url = "https://flakehub.com/f/catppuccin/vscode/*.tar.gz";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, flake-utils, home-manager, catppuccin, ... }@inputs:
    let
      inherit (self) outputs;
      gn = "xavier";
      gnsn = "xavierlauzon";
      handle = "xavierl";

      pkgsForSystem = system: nixpkgsSource: import nixpkgsSource {
        overlays = [
          inputs.comma.overlays.default
          inputs.nur.overlays.default
          inputs.nix-vscode-extensions.overlays.default
          inputs.catppuccin-vsc.overlays.default
          outputs.overlays.additions
          outputs.overlays.modifications
          outputs.overlays.stable-packages
          outputs.overlays.unstable-packages
        ];
        inherit system;
      };

      HomeConfiguration = args:
        let
          nixpkgs = args.nixpkgs or nixpkgs-stable;
        in
          home-manager.lib.homeManagerConfiguration {
            modules = [
              (import ./home)
              (import ./modules)
              catppuccin.homeModules.catppuccin
            ];
            extraSpecialArgs = {
              inherit (args) nixpkgs;
            } // args.extraSpecialArgs;
            pkgs = pkgsForSystem (args.system or "x86_64-linux") nixpkgs;
          };
    in flake-utils.lib.eachSystem [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ] (system: {
          legacyPackages = pkgsForSystem system nixpkgs;
      }) // {
        overlays = import ./overlays {inherit inputs;};
        homeConfigurations = {

          ###########
          # ORG: XL #
          ###########

          "xavierdesktop.${gn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "workstation";
              hostname = "xavierdesktop";
              username = gn;
              displays = 2;
              display_center = "DP-3";
              display_top = "HDMI-A-1";
              networkInterface = "enp6s0";
              inherit inputs outputs;
            };
          };

          "blackhawk.${gn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "blackhawk";
              username = gn;
              inherit inputs outputs;
            };
          };

          "blackhawk.sam" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "blackhawk";
              username = "sam";
              inherit inputs outputs;
            };
          };

          ###########
          # ORG: SD #
          ###########

          "sd111.${gnsn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "sd";
              role = "server";
              hostname = "sd111";
              username = gnsn;
              inherit inputs outputs;
            };
          };

          "newton.xl" = HomeConfiguration {
            extraSpecialArgs = {
              org = "sd";
              role = "server";
              hostname = "newton";
              username = "xl";
              inherit inputs outputs;
            };
          };

          "turing.xl" = HomeConfiguration {
            extraSpecialArgs = {
              org = "sd";
              role = "server";
              hostname = "turing";
              username = "xl";
              inherit inputs outputs;
            };
          };

      };

      inherit home-manager;
      inherit (home-manager) packages;
    };
}

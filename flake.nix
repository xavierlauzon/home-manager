{
  description = "Xavier's Home Manager configuration";

  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    comma.url = "github:nix-community/comma";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
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
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    NixVirt ={
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      gn = "xavier";
      gnsn = "xavierlauzon";
      handle = "xavierl";

      pkgsForSystem = system: import nixpkgs {
        overlays = [
          inputs.comma.overlays.default
          inputs.nur.overlay
          inputs.nix-vscode-extensions.overlays.default
          inputs.nixpkgs-wayland.overlay
          outputs.overlays.additions
          outputs.overlays.modifications
          outputs.overlays.unstable-packages
        ];
        inherit system;
      };

      HomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        modules = [
          (import ./home)
          (import ./modules)
        ];
        extraSpecialArgs = {

        };
        pkgs = pkgsForSystem (args.system or "x86_64-linux");

      } // { inherit (args) extraSpecialArgs; });
    in
      flake-utils.lib.eachSystem [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ]
        (
          system: rec {
          legacyPackages = pkgsForSystem system;
          }
        ) //
      {
        overlays = import ./overlays {inherit inputs;};
        homeConfigurations = {
          "xavierdesktop.${gn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "workstation";
              hostname = "xavierdesktop";
              username = gn;
              displays = 1;
              display_center = "DP-3";
              networkInterface = "enp6s0";
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

          "sd111.${gnsn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "sd";
              role = "server";
              hostname = "sd111";
              username = gnsn;
              inherit inputs outputs;
            };
          };
      };

      inherit home-manager;
      inherit (home-manager) packages;
    };
}

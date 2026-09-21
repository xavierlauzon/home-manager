{
  description = "Xavier's Home Manager configuration";

  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comma.url = "github:nix-community/comma";
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/NUR";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-colors.url = "github:misterio77/nix-colors";
    catppuccin.url = "github:catppuccin/nix";
    catppuccin-vsc.url = "https://flakehub.com/f/catppuccin/vscode/*.tar.gz";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, flake-utils, home-manager-stable, home-manager-unstable, catppuccin, ... }@inputs:
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
          nixpkgsInput = args.nixpkgs or nixpkgs-stable;
          hmInput = if nixpkgsInput == nixpkgs-unstable then home-manager-unstable else home-manager-stable;
        in
          hmInput.lib.homeManagerConfiguration {
            modules = [
              (import ./home)
              (import ./modules)
            ];
            extraSpecialArgs = {
              inherit (args) nixpkgs;
            } // args.extraSpecialArgs;
            pkgs = pkgsForSystem (args.system or "x86_64-linux") nixpkgsInput;
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
          "xavierdesktop.${gn}" = HomeConfiguration {
            nixpkgs = nixpkgs-unstable;
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
            nixpkgs = nixpkgs-unstable;
            extraSpecialArgs = {
              org = "xl";
              role = "workstation";
              hostname = "blackhawk";
              displays = 1;
              display_center = "HDMI-A-1";
              networkInterface = "public";
              username = gn;
              inherit inputs outputs;
            };
          };

          "blackhawk.sam" = HomeConfiguration {
            nixpkgs = nixpkgs-unstable;
            extraSpecialArgs = {
              org = "xl";
              role = "workstation";
              hostname = "blackhawk";
              displays = 1;
              display_center = "HDMI-A-1";
              networkInterface = "public";
              username = "sam";
              inherit inputs outputs;
            };
          };

          "raptor.${gn}" = HomeConfiguration {
            system = "aarch64-linux";
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "raptor";
              username = gn;
              inherit inputs outputs;
            };
          };

          "raptor.sam" = HomeConfiguration {
            system = "aarch64-linux";
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "raptor";
              username = gn;
              inherit inputs outputs;
            };
          };


          "trident.${gn}" = HomeConfiguration {
            system = "aarch64-linux";
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "trident";
              username = gn;
              inherit inputs outputs;
            };
          };

          "trident.sam" = HomeConfiguration {
            system = "aarch64-linux";
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "trident";
              username = gn;
              inherit inputs outputs;
            };
          };

          "falcon.${gn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "falcon";
              username = gn;
              inherit inputs outputs;
            };
          };

          "falcon.sam" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "falcon";
              username = gn;
              inherit inputs outputs;
            };
          };

          "spectre.${gn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "spectre";
              username = gn;
              inherit inputs outputs;
            };
          };

          "spectre.sam" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "spectre";
              username = gn;
              inherit inputs outputs;
            };
          };

          ###########
          # ORG: SD #
          ###########

          "bohr.${gnsn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "sd";
              role = "server";
              hostname = "bohr";
              username = gnsn;
              inherit inputs outputs;
            };
          };

          "turing.${gnsn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "sd";
              role = "server";
              hostname = "turing";
              username = gnsn;
              inherit inputs outputs;
            };
          };

          "pasteur.${gnsn}" = HomeConfiguration {
            nixpkgs = nixpkgs-unstable;
            extraSpecialArgs = {
              org = "sd";
              role = "server";
              hostname = "pasteur";
              username = gnsn;
              inherit inputs outputs;
            };
          };

          "banting.${gnsn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "sd";
              role = "server";
              hostname = "banting";
              username = gnsn;
              inherit inputs outputs;
            };
          };

          ###########
          # ORG: LM #
          ###########

          "paveway.${gn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "paveway";
              username = gn;
              inherit inputs outputs;
            };
          };

          "hellfire.${gn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "hellfire";
              username = gn;
              inherit inputs outputs;
            };
          };

          "maverick.${gn}" = HomeConfiguration {
            extraSpecialArgs = {
              org = "xl";
              role = "server";
              hostname = "maverick";
              username = gn;
              inherit inputs outputs;
            };
          };
      };

      inherit home-manager-stable home-manager-unstable;
      inherit (home-manager-stable) packages;
    };
}

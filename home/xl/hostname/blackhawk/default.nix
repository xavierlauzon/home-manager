# Shared host-level defaults for sam's workstation hosts. Host-specific values
# (hostname, displays, network interface) live in flake.nix extraSpecialArgs.
{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}: {
  imports = [
    ../../user/sam/host-default.nix
  ];
}

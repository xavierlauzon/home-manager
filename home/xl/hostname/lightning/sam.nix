# Shared sam workstation host config. Both blackhawk and lightning import the
# same module; host-specific values (hostname, displays, network interface)
# live in flake.nix extraSpecialArgs and hostname/<host>/default.nix.
{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}: {
  imports = [
    ../../user/sam/host-common.nix
  ];
}

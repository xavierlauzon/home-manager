# Shared host-level defaults for sam's workstation hosts (blackhawk, lightning).
# Host-specific values (hostname, displays, network interface) live in
# flake.nix extraSpecialArgs, not here.
{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
with lib; {
  host = {
    home = {
      applications = {
        # These hosts run Sunshine to share their screen as a Moonlight host
        # (e.g. the Windows laptop xavie@thebehemoth is the Moonlight client).
        sunshine.enable = true;
      };
    };
  };
}

{ config, lib, pkgs, specialArgs, ...}:
with lib;
{
  imports = [
  ];

  host = {
    home = {
      applications = {
        # blackhawk is the Sunshine HOST; the Windows laptop
        # (xavie@thebehemoth) is the Moonlight client / second monitor.
        sunshine.enable = true;
      };
      feature = {
      };
      service = {
      };
    };
  };
}
{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.zoxide;
in
  with lib;
{
  options = {
    host.home.applications.zoxide = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Directory traversal assistant";
      };
    };
  };

  config = mkIf cfg.enable {
     programs = {
       bash = {
         bashrcExtra = ''
           _ZO_DOCTOR=0
         '';
       };
       zoxide = {
         enable = true;
         enableBashIntegration = mkDefault true;
       };
     };
  };
}
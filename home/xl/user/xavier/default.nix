{ config, lib, pkgs, specialArgs, ...}:
let
  inherit (specialArgs) username;

  s = "xa";
  _p = "vi";
  _a = "er";
  m = "la";
  t = "uz";
  r = "on";
  a_ = ".";
  p_ = "com";

  email = "${username}@${s}${_p}${_a}${m}${t}${r}${a_}${p_}";
in
  with lib;
{
  host = {
    home = {
      applications = {
        git.enable = mkDefault true;
      };
    };
  };

  programs = {
    git = {
      userEmail = email;
    };
  };
}
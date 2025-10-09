{ config, lib, pkgs, specialArgs, ...}:
let
  inherit (specialArgs) username;

  s = "l";
  _p = "a";
  _a = "u";
  m = "z";
  t = "o";
  r = "n";
  a_ = ".";
  p_ = "xyz";

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

  imports = [
    "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
  ];

  services.vscode-server.enable = true;

  programs = {
    git = {
      userEmail = email;
      userName = "Samuel Pizette";
      lfs.enable = true;
    };
    #direnv = {
    #  enable = false;
    #  enableBashIntegration = true; # see note on other shells below
    #  nix-direnv.enable = true;
    #};
  };
}

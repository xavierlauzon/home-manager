{ config, lib, pkgs, specialArgs, ...}:
let
  s = "l";
  _p = "a";
  _a = "u";
  m = "z";
  t = "o";
  r = "n";
  a_ = ".";
  p_ = "xyz";
  username = "xavier";
  email = "${username}@${s}${_p}${_a}${m}${t}${r}${a_}${p_}";

  inherit (specialArgs) hostname role;
  inherit (pkgs.stdenv) isLinux isDarwin;
  homeDir = if isDarwin then "/Users/" else "/home/";
  if-exists = f: builtins.pathExists f;
  existing-imports = imports: builtins.filter if-exists imports;
in
{
  imports = [

  ] ++ existing-imports [
    ./hostname/${hostname}
    ./hostname/${hostname}.nix
    ./role/${role}
    ./role/${role}.nix
  ];

  home = {
    homeDirectory = homeDir+username;
    inherit username;

    packages = with pkgs;
    [

    ]
    ++ lib.optionals ( role == "workstation" || role == "server" )
    [

    ];
  };

  programs = {
    git = {
      userEmail = email;
    };
  };
}

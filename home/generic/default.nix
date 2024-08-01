{ config, lib, pkgs, specialArgs, ...}:
let
  s = "xa";
  _p = "vi";
  _a = "er";
  m = "la";
  t = "uz";
  r = "on";
  a_ = ".";
  p_ = "com";
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

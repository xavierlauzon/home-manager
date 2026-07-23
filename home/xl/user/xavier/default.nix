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

  programs = {
    git-credential-oauth.enable = true;
    git = {
      settings.user.email = email;
      settings.user.name = "Xavier Lauzon";
      lfs.enable = true;
      settings = {
        credential.helper = [
          "cache --timeout=86400"
          "oauth"
        ];
        credential."https://git.lauzon.xyz".oauthScopes = "read_repository write_repository";
        credential."https://git.lauzon.xyz".oauthAuthURL = "/login/oauth/authorize";
        credential."https://git.lauzon.xyz".oauthTokenURL = "/login/oauth/access_token";
        credential."https://git.lauzon.xyz".oauthDeviceAuthURL = "/login/oauth/authorize_device";
      };
    };
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
  };
}

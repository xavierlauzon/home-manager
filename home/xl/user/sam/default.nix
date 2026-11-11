{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}: let
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
  with lib; {
    host = {
      home = {
        applications = {
          git.enable = mkDefault true;
        };
      };
    };
    programs = {
      # The oauth device-flow credential helper was the source of interactive
      # auth prompts. git.lauzon.xyz now authenticates with the sops-encrypted
      # PAT (below), so the oauth helper is disabled and never consulted.
      git-credential-oauth.enable = false;
      git = {
        settings.user.email = email;
        settings.user.name = "Cinder";
        lfs.enable = true;
        settings = {
          # Non-git.lauzon.xyz hosts (e.g. gist) use a short-lived cache; kept
          # for convenience only. github.com credentials come from gh's own
          # credential helper (see modules/applications/cli/gh.nix).
          credential.helper = [
            "cache --timeout=86400"
          ];
          # git.lauzon.xyz uses the sops-encrypted PAT (deployed by sops-nix to
          # ~/.config/git/lauzon.env) instead of the oauth device flow, which is
          # unreliable in cron / headless push. This helper reads the token from
          # the sops-decrypted env file, so git never falls through to oauth for
          # this host.
          credential."https://git.lauzon.xyz".helper = "!f() { echo username=sam; echo password=$(sed -n 's/^GIT_LAUZON_TOKEN=//p' \"$HOME/.config/git/lauzon.env\"); }; f";
          # github.com credentials are handled by gh's own credential helper
          # (`gh auth git-credential`, wired by the gh module), which reads the
          # sops-deployed ~/.config/gh/hosts.yml. No custom helper needed here.
        };
      };
      #direnv = {
      #  enable = false;
      #  enableBashIntegration = true; # see note on other shells below
      #  nix-direnv.enable = true;
      #};
    };
  }

{config, lib, pkgs, specialArgs, ...}:

let
  cfg = config.host.home.user.sam.secrets.ssh.lumae;
in
  with lib;
{
  options = {
    host.home.user.sam.secrets.ssh.lumae = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable SSH to lumae.net hosts (hellfire/paveway/maverick) with the xl keypair";
      };
    };
  };

  config = mkIf cfg.enable {
    # Reuses the sops-protected xl-id_ed25519 keypair (see secrets/ssh/xl).
    # The *.lumae.net wildcard matches the public and *.internal.lumae.net mesh names.
    programs.ssh.settings = {
      "*.lumae.net" = {
        User = "sam";
        IdentityFile = config.sops.secrets."ssh/xl-id_ed25519".path;
      };
      # Short aliases (ssh maverick / ssh sam@maverick) resolve to the mesh FQDN.
      "maverick hellfire paveway" = {
        HostName = "%h.internal.lumae.net";
        User = "sam";
        IdentityFile = config.sops.secrets."ssh/xl-id_ed25519".path;
      };
    };
  };
}

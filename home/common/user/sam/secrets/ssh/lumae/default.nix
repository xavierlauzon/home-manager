{config, lib, pkgs, specialArgs, ...}:

let
  cfg = config.host.home.user.sam.secrets.ssh.lumae;

  # spamtrap: internal names are reassembled from fragments so web crawlers
  # don't index the plaintext mesh domain/hosts. Kept consistent with the
  # xl/sd SSH configs. (Fragile by design — intended as a stopgap.)
  mk = lib.concatStrings;
  l = "l"; u = "u"; m = "m"; a = "a"; e = "e"; dot = "."; n = "n"; t = "t";
  domain = mk [ l u m a e dot n e t ];                       # lumae.net
  internal = "internal";
  maverick = mk [ "m" "a" "v" "e" "r" "i" "c" "k" ];
  hellfire = mk [ "h" "e" "l" "l" "f" "i" "r" "e" ];
  paveway  = mk [ "p" "a" "v" "e" "w" "a" "y" ];
  hosts = [ maverick hellfire paveway ];
in
  with lib;
{
  options = {
    host.home.user.sam.secrets.ssh.lumae = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable SSH to the mesh hosts with the xl keypair";
      };
    };
  };

  config = mkIf cfg.enable {
    # Reuses the sops-protected xl-id_ed25519 keypair (see secrets/ssh/xl).
    # The wildcard matches both the public and the internal mesh FQDNs.
    programs.ssh.settings = {
      "*.${domain}" = {
        User = "sam";
        IdentityFile = config.sops.secrets."ssh/xl-id_ed25519".path;
      };
      # Short aliases (e.g. `ssh maverick`) resolve to the internal mesh FQDN.
      "${concatStringsSep " " hosts}" = {
        HostName = "%h.${internal}.${domain}";
        User = "sam";
        IdentityFile = config.sops.secrets."ssh/xl-id_ed25519".path;
      };
    };
  };
}

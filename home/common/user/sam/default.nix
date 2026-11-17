{ config, inputs, lib, pkgs, specialArgs, ... }:

with lib;
{
  imports = [
    ./secrets
  ];

  # Host guard: abort activation if this generation was built for a
  # different machine. Agent sessions have copy-pasted a
  # `--flake .#blackhawk.sam` switch onto lightning (and vice versa),
  # silently deploying the wrong host's config; the subsequent rebuilds
  # then reshuffle Hyprland monitors/workspaces on every switch.
  # This is a runtime check inside the activation script (pure-eval
  # safe) and runs before writeBoundary, so nothing is linked.
  home.activation.hostGuard = hm.dag.entryBefore [ "writeBoundary" ] ''
    __hm_expected_host="${specialArgs.hostname or ""}"
    __hm_actual_host="$(cat /proc/sys/kernel/hostname)"
    if [ -n "$__hm_expected_host" ] && [ "$__hm_expected_host" != "$__hm_actual_host" ]; then
      echo "home-manager: ABORT - this generation was built for host '$__hm_expected_host' but we are on '$__hm_actual_host'. Use --flake .#$__hm_actual_host.<user>." >&2
      exit 1
    fi
  '';
}

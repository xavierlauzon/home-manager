# NixOS-level prerequisites for the Sunshine host (blackhawk)
#
# The home-manager module `modules/applications/gui/sunshine.nix` covers the
# user-space side (package, config, virtual display, user service), but the
# following NixOS options cannot be expressed in home-manager.
#
# HOW TO USE: import this file from your NixOS system configuration, e.g.
#
#   { config, lib, ... }:
#   {
#     imports = [ /path/to/sunshine-prereqs.nix ];
#   }
#
# Notes:
#   - The user `sam` is hardcoded below; adjust to your actual user if needed.
#   - If you also want Moonlight clients to reach the host over the normal LAN
#     (not just the direct link), keep the firewall ports open globally. If you
#     only want the direct ethernet link, restrict `networking.firewall` rules
#     to that interface instead.
#   - `hardware.graphics.enable` is usually already enabled on a desktop;
#     it is required for VAAPI (radeonsi) encoding.
{
  config,
  lib,
  pkgs,
  ...
}: {
  # --- Virtual input (mouse/keyboard injected by the Moonlight client) ---
  # Creates /dev/uinput + group `uinput`. Sunshine's own udev rules also match
  # /dev/uhid and the libvirtualhid nodes, so the user needs BOTH groups.
  hardware.uinput.enable = true;

  # --- VAAPI / hardware graphics for AMF-free AMD encoding ---
  hardware.graphics.enable = true;

  # --- User groups for the streaming session user ---
  users.users.sam.extraGroups = ["input" "uinput"];

  # --- Firewall: Sunshine ports ---
  # TCP 47984 (RTSP), 47989 (HTTPS/web UI), 47990 (web UI alt), 48010
  # UDP 47998, 47999, 48000 (video/audio/control), 48002 (mic), 48010
  networking.firewall.allowedTCPPorts = [47984 47989 47990 48010];
  networking.firewall.allowedUDPPorts = [47998 47999 48000 48002 48010];

  # --- Direct 2.5GbE link to the Moonlight client (thebehemoth) ---
  # Streaming path: host = 192.168.88.1, client = 192.168.88.2, so the stream
  # bypasses the LAN/Wi-Fi. blackhawk has TWO Realtek RTL8125 2.5GbE NICs:
  #   - eno1  -> the `public` bridge (LAN switch, many MACs) — do NOT touch.
  #   - eth1  -> the spare NIC, reserved for this direct link (the client's
  #              Realtek 2.5GbE port is statically configured at 192.168.88.2).
  # Verified healthy: 0% loss, ~0.2 ms RTT at 2.5 Gbps. Moonlight (thebehemoth)
  # connects to this host via 192.168.88.1.
  networking.interfaces.eth1.useDHCP = false;
  networking.interfaces.eth1.ipv4.addresses = [
    {
      address = "192.168.88.1";
      prefixLength = 24;
    }
  ];
}

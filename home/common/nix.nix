{ inputs, config, lib, pkgs, ... }:
with lib;
{
  home = {
    activation = {
      report-changes = ''
        PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
        if [ ! -d /nix/var/nix/profiles/per-user/$USER ]; then
            if [ -d $HOME/.local/state/nix/profiles ] ; then
                PROFILE_PATH="$HOME/.local/state/nix/profiles"
            else
                PROFILE_PATH=null
            fi
        else
            if [ -d /nix/var/nix/profiles/per-user/$USER ] && [ -d $HOME/.local/state/nix/profiles ] ; then
                PROFILE_PATH="$HOME/.local/state/nix/profiles"
            else
                PROFILE_PATH="/nix/var/nix/profiles/per-user/$USER"
            fi
        fi

        if [ -n "$PROFILE_PATH" ] && [ "$PROFILE_PATH" != "null" ]; then
            mkdir -p $HOME/.local/state/home-manager/logs
            _logfile_now=$(date +'%Y%m%d%H%M%S')
            if [ $(ls "$PROFILE_PATH"/home-manager-*-link 2> /dev/null | wc -l) -gt 0 ] ; then
                ${pkgs.nvd}/bin/nvd diff $(ls -dv $PROFILE_PATH/home-manager-*-link | tail -2)
                nvd diff $(ls -dv $PROFILE_PATH/home-manager-*-link | tail -2) > "$HOME/.local/state/home-manager/logs/$_logfile_now-$USER-$(ls -dv $PROFILE_PATH/home-manager-*-link | tail -1 | cut -d '-' -f 3)-$(readlink $(ls -dv $PROFILE_PATH/home-manager-*-link | tail -1)| cut -d / -f 4 | cut -d - -f 1).log"
                if grep -q "No version or selection state changes" "$HOME/.local/state/home-manager/logs/$_logfile_now-$USER-$(ls -dv $PROFILE_PATH/home-manager-*-link | tail -1 | cut -d '-' -f 3)-$(readlink $(ls -dv $PROFILE_PATH/home-manager-*-link | tail -1)| cut -d / -f 4 | cut -d - -f 1).log" ; then
                    rm -rf "$HOME/.local/state/home-manager/logs/$_logfile_now-$USER-$(ls -dv $PROFILE_PATH/home-manager-*-link | tail -1 | cut -d '-' -f 3)-$(readlink $(ls -dv $PROFILE_PATH/home-manager-*-link | tail -1)| cut -d / -f 4 | cut -d - -f 1).log"
                fi
            elif [ $(ls "$PROFILE_PATH"/profile-*-link 2> /dev/null | wc -l) -gt 0 ]; then
                ${pkgs.nvd}/bin/nvd diff $(ls -dv $PROFILE_PATH/profile-*-link | tail -2)
                nvd diff $(ls -dv $PROFILE_PATH/profile-*-link | tail -2) > "$HOME/.local/state/home-manager/logs/$_logfile_now-$USER-$(ls -dv $PROFILE_PATH/profile-*-link | tail -1 | cut -d '-' -f 3)-$(readlink $(ls -dv $PROFILE_PATH/profile-*-link | tail -1)| cut -d / -f 4 | cut -d - -f 1).log"
                if grep -q "No version or selection state changes" "$HOME/.local/state/home-manager/logs/$_logfile_now-$USER-$(ls -dv $PROFILE_PATH/profile-*-link | tail -1 | cut -d '-' -f 3)-$(readlink $(ls -dv $PROFILE_PATH/profile-*-link | tail -1)| cut -d / -f 4 | cut -d - -f 1).log" ; then
                    rm -rf "$HOME/.local/state/home-manager/logs/$_logfile_now-$USER-$(ls -dv $PROFILE_PATH/profile-*-link | tail -1 | cut -d '-' -f 3)-$(readlink $(ls -dv $PROFILE_PATH/profile-*-link | tail -1)| cut -d / -f 4 | cut -d - -f 1).log"
                fi
            fi

        else
            echo "ERROR - Can't write Home-Manager generation log file"
        fi
      '';
    };
  };

  nix = {
    settings = {
      auto-optimise-store = mkDefault true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      use-xdg-base-directories = mkDefault true;
      warn-dirty = mkDefault false;
    };

    package = pkgs.nixFlakes;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  };

  nixpkgs = {
    config = {
      allowUnfree = mkDefault true;
      allowUnfreePredicate = (_: true);
    };
  };

  programs = {
    nix-index = {
      enable = mkDefault true;
      enableBashIntegration = mkDefault true;
    };
  };
}

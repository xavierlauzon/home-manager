# HOME

My home-manager config 

Based off [tiredofit/home](https://github.com/tiredofit/home).

## Tree Structure

- `flake.nix`: Entrypoint for home configurations.
- `dotfiles`: Configuration files that are outside of the Home-Manager configuration (not migrated to nix)
- `home`: Home Manager Configurations, accessible via `home-manager switch --flake `.
  - Split in between 'orgs' and common configuration this creates isolation. Based on 'roles' defaults are loaded
    and then each subfolder creates a different level of configuration specific to that host or role.
    - `common`: Shared configurations consumed by all users.
      - `role`: Files related to what "role" is being selected as a template
      - `secrets`: Secrets that are available to all users
    - `generic`: The 'generic' org to allow for isolation of configurations, secrets and config from various clients
    - `xl`: The 'xl' org to allow for isolation of configurations, secrets and config from various clients
      - `secrets`: Secrets that are specific to the 'xl' org
      - `<hostname>`: Optional subfolder to load more configuration files based on the home-manager profiles name
      - `<role>`: Optional subfolder to load more configuration files based on the roles name
      - `<users>`: Load some specific user profile information
    - `sd`: Similar to the above org, just another org for isolation
    - `...`
- `modules`: Modules that are specific to this installation
  - `applications`: Applications and configurations
    - `cli`: Command line tools
    - `gui`: Programs with a graphical interface
  - `desktop`: Desktop environments
    - `displayServer`: `x` or `wayland` configuration
    - `utils`: Programs specific to desktop and window environments
      - `agnostic` - runs great on whatever window manager
      - `wayland` - wayland specific utilities to complement window managers
      - `x` - x specific utilties to complement window managers
    - `windowManager`: A variety of configurations depending on the type of window manager, or Desktop environment
  - `feature` - Switchable features
  - `service` - Daemons and services

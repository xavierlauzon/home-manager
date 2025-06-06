{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.lsd;
in
  with lib;
{
  options = {
    host.home.applications.lsd = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Directory List Alternative";
      };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      lsd = {
        enable = true;
        settings = {
          classic = false;
          blocks = [ "permission" "user" "group" "size" "date" "name" ];
          date = "date";
          ignore-globs = [ ".git" ".hg" ];
          total-size = true;
          layout = "grid";
          symlink-arrow = "⇒";
          color = {
            when = "auto";
            theme = "custom";
          };
          sorting = {
            column = "name";
            reverse = false;
            dir-grouping = "first";
          };
        };
        colors = {
          permission = {
            read = "dark_yellow";
            write = "dark_blue";
            exec = "dark_green";
            exec-sticky = 5;
            no-access = 245;
            octal = 6;
            acl = "dark_cyan";
            context = "cyan";
          };
          date = {
            hour-old = 40;
            day-old = 42;
            older = 36;
          };
          size = {
            none = 245;
            small = 229;
            medium = 216;
            large = 172;
          };
          inode = {
            valid = 13;
            invalid = 245;
          };
          links = {
            valid = 13;
            invalid = 245;
            tree-edge = 245;
          };
        };
      };

      #bash.shellAliases = {
      #  ls = "lsd --hyperlink=auto" ; # directory list alternative
      #};
    };
  };
}

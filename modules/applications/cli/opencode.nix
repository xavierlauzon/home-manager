{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.opencode;
in
  with lib;
{
  options = {
    host.home.applications.opencode = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "AI coding agent";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.opencode-desktop
    ];

    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        tools = {
          websearch = false;
          webfetch = false;
          firecrawl_firecrawl_agent = false;
          firecrawl_firecrawl_agent_status = false;
          firecrawl_firecrawl_extract = false;
        };
      };
    };

    programs.mcp = {
      enable = true;
      servers = {
        firecrawl = {
          command = "${pkgs.firecrawl-mcp}/bin/firecrawl-mcp";
          env = {
            FIRECRAWL_API_URL = "https://crawl.lauzon.xyz";
            FIRECRAWL_NO_SEARCH_FEEDBACK = "1";
            FIRECRAWL_NO_ENDPOINT_FEEDBACK = "1";
          };
        };
      };
    };
  };
}

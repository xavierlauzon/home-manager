{ lib
, buildNpmPackage
, fetchzip
, nodejs_22
}:

buildNpmPackage rec {
  pname = "firecrawl-mcp";
  version = "3.22.3";

  src = fetchzip {
    url = "https://registry.npmjs.org/firecrawl-mcp/-/firecrawl-mcp-${version}.tgz";
    hash = "sha256-F2upDxwhp2GrzUP53WVHUOFcICQ4Uu3PdcsW1O0kkkM=";
  };

  nativeBuildInputs = [ nodejs_22 ];

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  dontNpmBuild = true;
  npmDepsHash = "sha256-AuwwjcLFcaYgLZ/zG9Vwmv+bMx4+eLdac8CdKL4AsIE=";

  meta = with lib; {
    description = "MCP server for Firecrawl - search, scrape, and interact with the web";
    homepage = "https://github.com/firecrawl/firecrawl-mcp-server";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "firecrawl-mcp";
  };
}

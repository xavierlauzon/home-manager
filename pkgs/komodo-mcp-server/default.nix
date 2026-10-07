{ lib
, buildNpmPackage
, nodejs_22
}:

# Builds the local fork at ~/src/misc/mcp/mcp-komodo (adds multi-host support).
# NOTE: local-path source — not reproducible on other machines. Rebuilds pick
# up the latest working tree; push + fetchgit can replace this if reproducibility
# is ever needed.
buildNpmPackage rec {
  pname = "komodo-mcp-server";
  version = "1.4.1";

  src = lib.cleanSourceWith {
    src = /home/sam/src/misc/mcp/mcp-komodo;
    filter = path: type:
      let base = baseNameOf path;
      in !(type == "directory" && (base == "node_modules" || base == "build" || base == ".git"))
      && base != ".env";
  };

  nativeBuildInputs = [ nodejs_22 ];

  # `npm run build` (tsc -> build/) is run by buildNpmPackage's default build phase.
  npmDepsHash = "sha256-6ra4C8bBGRdRILc4p2AIPkt89iMsXgVoJx+GIl4dpN0=";

  meta = with lib; {
    description = "Model Context Protocol Server for Komodo (Container Manager) — multi-host fork";
    homepage = "https://git.lauzon.xyz/sam/mcp-komodo";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "komodo-mcp-server";
  };
}

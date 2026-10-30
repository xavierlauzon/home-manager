{
  lib,
  buildNpmPackage,
  fetchgit,
  nodejs_24,
  python3,
}:
# Local-first Proton Mail MCP server + CLI, talking IMAP/SMTP to a local
# Proton Bridge (127.0.0.1:1143 / 1025). Reproducible, pinned to a commit.
# See the bridge service module (modules/service/protonmail-bridge.nix).
buildNpmPackage rec {
  pname = "proton-mail-bridge-client";
  version = "2.17.0";

  src = fetchgit {
    url = "https://github.com/googlarz/proton-mail-bridge-client";
    rev = "ec133053c074fabfcce6959ba5ff815633addf1c";
    sha256 = "sha256-R8a1oWxu2X8LHKx067D/P9na3KCxBgnhu0vaGM32cZY=";
  };

  nativeBuildInputs = [python3];

  # `npm run build` (tsc -> dist/) is run by buildNpmPackage's default build
  # phase. better-sqlite3 compiles from source during npm install.
  npmDepsHash = "sha256-mmmX5XRmY9/Ku43cxa0UyOqiidTwFEbV/PtoS8cSUdU=";

  meta = with lib; {
    description = "Local-first Proton Mail MCP server and CLI via Proton Bridge";
    homepage = "https://github.com/googlarz/proton-mail-bridge-client";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "proton-mail-bridge-mcp";
  };
}

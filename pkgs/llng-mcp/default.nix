{ lib
, buildNpmPackage
, fetchzip
, nodejs_22
}:

# MCP server for LemonLDAP::NG Web-SSO (by LinaGora, the LLNG vendor).
# Talks to LLNG instances via SSH / kubectl / REST per ~/.llng-mcp.json.
# Tarball ships prebuilt dist/, so no build phase needed.
buildNpmPackage rec {
  pname = "llng-mcp";
  version = "0.2.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/llng-mcp/-/llng-mcp-${version}.tgz";
    hash = "sha256-/2q/HFPL6CHz8cwUnU68CLV1XiG19h6Q7sBXdOEOsSk=";
  };

  nativeBuildInputs = [ nodejs_22 ];

  # npm tarball ships no package-lock.json; use the one from the v0.2.0 tag.
  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  dontNpmBuild = true;
  npmDepsHash = "sha256-EZN6mQysxJTzXM9qaPm0WmZmFli6bUhOtxsa73pmW04=";

  meta = with lib; {
    description = "MCP server for LemonLDAP::NG Web-SSO (config, sessions, OIDC, SAML, 2FA)";
    homepage = "https://github.com/linagora/llng-mcp";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "llng-mcp";
  };
}

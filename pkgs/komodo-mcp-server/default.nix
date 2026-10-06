{ lib
, buildNpmPackage
, fetchzip
, nodejs_22
}:

buildNpmPackage rec {
  pname = "komodo-mcp-server";
  version = "1.5.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/komodo-mcp-server/-/komodo-mcp-server-${version}.tgz";
    hash = "sha256-vogLzMlILtZtzsR8ra1/qVtB1izo/gA0k7g2qM5Sgmg=";
  };

  nativeBuildInputs = [ nodejs_22 ];

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  dontNpmBuild = true;
  npmDepsHash = "sha256-T9t1twVLQpyErSx9tW5o0VjJXcUn9gxxN1/upgvwGOU=";

  meta = with lib; {
    description = "Model Context Protocol Server for Komodo (Container Manager)";
    homepage = "https://github.com/MP-Tool/komodo-mcp-server";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "komodo-mcp-server";
  };
}

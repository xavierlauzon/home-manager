{ lib
, python3
, fetchFromGitHub
, fetchPypi
}:

# LiteAdmin MCP — official BerriAI connector to administer a LiteLLM gateway
# (keys, deployments, teams, budgets, spend, logs) over MCP.
# Pinned to tag v0.1.0. The project hard-pins mcp==2.2.0 + httpx2==2.13.0,
# which nixpkgs does not carry (nixpkgs has mcp 1.29.x — pre-MCPServer-rename
# API), so those four pypi deps are vendored here and everything else uses
# nixpkgs python3Packages.
let
  ps = python3.pkgs;

  # Upstream pypi sdists source version+readme dynamically via the
  # uv-dynamic-versioning / hatch-fancy-pypi-readme hatch plugins. We pin
  # versions in nix, so drop those plugin sections and set them statically
  # (strip-dynamic-plugins.py). $version is already exported by stdenv.
  stripDynamicVersionPlugins = ''
    if grep -q uv-dynamic-versioning pyproject.toml; then
      awk '/^\[/ { skip = ($0 ~ /uv-dynamic-versioning|fancy-pypi-readme|hatch\.version/) }
           skip { next } { print }' pyproject.toml > pyproject.toml.tmp
      mv pyproject.toml.tmp pyproject.toml
      python ${./strip-dynamic-plugins.py} "$version" pyproject.toml
    fi
  '';

  httpcore2 = ps.buildPythonPackage rec {
    pname = "httpcore2";
    version = "2.13.0";
    format = "pyproject";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256:2adc8be4fb285fbcd6d894298db3b52c177e74b6674eda3a76bd36be3292a3db";
    };
    nativeBuildInputs = [ ps.hatchling ];
    postPatch = stripDynamicVersionPlugins;
    propagatedBuildInputs = with ps; [ h11 truststore anyio ];
    doCheck = false;
  };

  httpx2 = ps.buildPythonPackage rec {
    pname = "httpx2";
    version = "2.13.0";
    format = "pyproject";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256:81bd07dc67a3701729ef1f777a3c00c915d4539604fdb5afd327f8682f6b7b44";
    };
    nativeBuildInputs = [ ps.hatchling ];
    postPatch = stripDynamicVersionPlugins;
    propagatedBuildInputs = with ps; [ httpcore2 anyio idna truststore ];
    doCheck = false;
  };

  mcp-types = ps.buildPythonPackage rec {
    pname = "mcp_types";
    version = "2.2.0";
    format = "pyproject";
    src = fetchPypi {
      inherit version;
      pname = "mcp_types"; # pypi sdist filename uses the underscore form
      hash = "sha256:d3ed53703ddd10d9c6399f29d322bb66f3f67ab41348ac8556ba23e07fedefad";
    };
    nativeBuildInputs = [ ps.hatchling ];
    postPatch = stripDynamicVersionPlugins;
    propagatedBuildInputs = with ps; [ pydantic typing-extensions ];
    doCheck = false;
  };

  mcp_2_2 = ps.buildPythonPackage rec {
    pname = "mcp";
    version = "2.2.0";
    format = "pyproject";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256:2dc37ecb1974becdcebdbf7561e7c15a07dbbf20ba21ba16c3593b3038b3afbd";
    };
    nativeBuildInputs = [ ps.hatchling ];
    postPatch = stripDynamicVersionPlugins;
    propagatedBuildInputs = with ps; [
      anyio
      jsonschema
      opentelemetry-api
      pydantic
      pyjwt
      python-multipart
      starlette
      sse-starlette
      typing-extensions
      uvicorn
    ] ++ [ httpx2 mcp-types ];
    doCheck = false;
  };
in
ps.buildPythonApplication rec {
  pname = "litellm-admin-mcp";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "BerriAI";
    repo = "liteadmin-mcp";
    tag = "v0.1.0";
    hash = "sha256-vgT9FZmtsi7OMwSj9wEZqvyTkK5dsapCiamnDvgL13M=";
  };

  nativeBuildInputs = [ ps.hatchling ];

  propagatedBuildInputs = [ mcp_2_2 httpx2 ] ++ (with ps; [ jsonschema uvicorn ]);

  pythonImportsCheck = [ "litellm_admin_mcp" ];

  meta = with lib; {
    description = "MCP connector for administering a LiteLLM gateway (keys, deployments, teams, budgets, spend)";
    homepage = "https://github.com/BerriAI/liteadmin-mcp";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "litellm-admin-mcp";
  };
}

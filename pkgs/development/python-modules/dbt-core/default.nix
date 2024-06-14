{
  lib,
  agate,
  buildPythonPackage,
  cffi,
  click,
  colorama,
  dbt-extractor,
  dbt-semantic-interfaces,
  fetchFromGitHub,
  hologram,
  idna,
  isodate,
  jinja2,
  logbook,
  mashumaro,
  minimal-snowplow-tracker,
  networkx,
  packaging,
  pathspec,
  protobuf,
  python3,
  pythonOlder,
  pytz,
  pyyaml,
  requests,
  setuptools,
  sqlparse,
  typing-extensions,
  urllib3,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "dbt-core";
  version = "1.7.14";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "dbt-labs";
    repo = "dbt-core";
    rev = "refs/tags/v${version}";
    hash = "sha256-4PydrJGhriGCB6oc4kQE8/a24Sn9cqZhoKsiBJuEDYM=";
  };

  sourceRoot = "${src.name}/core";

  pythonRelaxDeps = [
    "agate"
    "click"
    "mashumaro"
    "networkx"
    "logbook"
    "pathspec"
    "urllib3"
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    agate
    cffi
    click
    colorama
    dbt-extractor
    dbt-semantic-interfaces
    hologram
    idna
    isodate
    jinja2
    logbook
    mashumaro
    minimal-snowplow-tracker
    networkx
    packaging
    pathspec
    protobuf
    pytz
    pyyaml
    requests
    sqlparse
    typing-extensions
    urllib3
    werkzeug
  ] ++ mashumaro.optional-dependencies.msgpack;

  # tests exist for the dbt tool but not for this package specifically
  doCheck = false;

  passthru = {
    withAdapters = python3.pkgs.callPackage ./with-adapters.nix { };
  };

  meta = with lib; {
    description = "Enables data analysts and engineers to transform their data using the same practices that software engineers use to build applications";
    longDescription = ''
      The dbt tool needs adapters to data sources in order to work. The available
      adapters are:

        dbt-bigquery
        dbt-postgres
        dbt-redshift
        dbt-snowflake

      An example of building this package with a few adapters:

        dbt.withAdapters (adapters: [
          adapters.dbt-bigquery
          adapters.dbt-postgres
        ])
    '';
    homepage = "https://github.com/dbt-labs/dbt-core";
    changelog = "https://github.com/dbt-labs/dbt-core/blob/v${version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [
      mausch
      tjni
    ];
    mainProgram = "dbt";
  };
}

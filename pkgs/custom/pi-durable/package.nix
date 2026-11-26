{
  lib,
  buildNpmPackage,
  makeWrapper,
  nodejs_24,
}:
# @earendil-works/pi-durable is a library (no bin). This bundles it with its
# pi-ai/chord peers and a small host CLI (cli.mjs) so it is usable directly:
# SQLite-backed sessions, built-in coding tools, crash-safe resume.
# Bump: edit versions in package.json, `npm install --package-lock-only
# --ignore-scripts`, then refresh npmDepsHash from the mismatch error.
buildNpmPackage {
  pname = "pi-durable";
  version = "1.6.1";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [./package.json ./package-lock.json ./cli.mjs];
  };

  nodejs = nodejs_24;
  npmDepsHash = "sha256-3eAS1Wc0w6XM/QLdjsxU41nkG11WptdkvyULxY3qnQg=";
  npmFlags = ["--ignore-scripts"];
  dontNpmBuild = true;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/pi-durable" "$out/bin"
    cp -r package.json cli.mjs node_modules "$out/lib/pi-durable/"
    makeWrapper ${lib.getExe nodejs_24} "$out/bin/pi-durable" \
      --add-flags "$out/lib/pi-durable/cli.mjs" \
      --set-default NODE_NO_WARNINGS 1
    runHook postInstall
  '';

  meta = {
    description = "Durable conversation, task, and document runtime for Pi, with a minimal crash-safe CLI host";
    homepage = "https://github.com/earendil-works/pi/tree/main/packages/durable";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [DivitMittal];
    platforms = lib.platforms.unix;
    mainProgram = "pi-durable";
  };
}

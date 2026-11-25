{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) optionalString;
  version = "0.171.0";
  platforms = {
    x86_64-darwin = {
      suffix = "darwin-x64";
      hash = "sha512-pwN5uNEKx/mZjwBEf/6CKq6SJMfJS5kruV3sJQAk7ebIPvC58Ote3CicIxETDZtjLj35rNv3PLPd7mHCg6hGPw==";
    };
    aarch64-darwin = {
      suffix = "darwin-arm64";
      hash = "sha512-hIYTkRUpuYpkVfTq4cpby0PXqhAVcIgE7f6FoyY1lt2RyARj3GXS1Can/dIYUBItVhXzhb98HYHZNzCX74QRlQ==";
    };
    x86_64-linux = {
      suffix = "linux-x64";
      hash = "sha512-l66NZkQgdk2C3pbcfULDz42yEUB581MVA6I+Y43Wp4OIqEy73HCdmZ0GTjeAHY2ycuH4N00d9VsLrwT1jxshTw==";
    };
    aarch64-linux = {
      suffix = "linux-arm64";
      hash = "sha512-9z17t4bbUJ9UCIb49O4PoA+ki+45q3rd8nZ8PeH6sYnlKkBld/Xpo/OS3h3Ti954+foshX4o7k5TCU8N7zzqQA==";
    };
  };
  platform = platforms.${pkgs.stdenv.hostPlatform.system} or (throw "codex: unsupported system ${pkgs.stdenv.hostPlatform.system}");
  # The copied package root must stay a Nix store path. Codex refuses to copy
  # a CLI package that lives inside CODEX_HOME, so the wrapper only sets the
  # env var and execs the store binary.
  codexNative = pkgs.stdenvNoCC.mkDerivation {
    pname = "codex";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}-${platform.suffix}.tgz";
      inherit (platform) hash;
    };
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R vendor/*/. "$out/"
      runHook postInstall
    '';
    dontStrip = true;
    meta.mainProgram = "codex";
  };
  codexPackage = pkgs.writeShellScriptBin "codex" ''
    ${optionalString config.home.preferXdgDirectories ''export CODEX_HOME="${config.xdg.configHome}/codex"''}
    exec ${codexNative}/bin/codex "$@"
  '';
in {
  programs.codex = {
    enable = true;
    mutableUserSettings = true;
    syncDaemon = true;
    package = codexPackage // {inherit version;};
  };
}

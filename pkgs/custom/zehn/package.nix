{
  lib,
  stdenv,
  zig,
  sources,
}: let
  inherit (sources.zehn) version src;
in
  stdenv.mkDerivation {
    pname = "zehn";
    inherit version src;

    nativeBuildInputs = [zig.hook];

    meta = {
      description = "Fuzzy-find any prompt across claude, codex, pi & opencode histories, then resume that session";
      homepage = "https://github.com/al3rez/zehn";
      license = {
        fullName = "PolyForm Noncommercial 1.0.0";
        url = "https://polyformproject.org/licenses/noncommercial/1.0.0/";
        free = false;
      };
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = lib.platforms.unix;
      mainProgram = "zehn";
    };
  }

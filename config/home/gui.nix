{
  lib,
  pkgs,
  config,
  ai-nixCfg ? null,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkMerge optional;

  system = pkgs.stdenv.hostPlatform.system;
  flakePackages =
    if ai-nixCfg == null || !(builtins.hasAttr system (ai-nixCfg.packages or {}))
    then {}
    else builtins.getAttr system ai-nixCfg.packages;

  attrOrNull = name: attrs:
    if builtins.hasAttr name attrs
    then builtins.getAttr name attrs
    else null;

  supportsHost = package: let
    platforms = package.meta.platforms or [];
  in
    platforms == [] || builtins.elem system platforms;

  supportedPackageOrNull = name: attrs: let
    package = attrOrNull name attrs;
  in
    if package != null && supportsHost package
    then package
    else null;

  brewCasks = pkgs.brewCasks or {};

  darwinCaskOrNull = name:
    if pkgs.stdenv.isDarwin
    then supportedPackageOrNull name brewCasks
    else null;

  hostPackageOrNull = name:
    if !pkgs.stdenv.isDarwin
    then supportedPackageOrNull name pkgs
    else null;

  flakePackageOrNull = name:
    if !pkgs.stdenv.isDarwin
    then supportedPackageOrNull name flakePackages
    else null;

  firstNonNull = values: let
    matches = builtins.filter (value: value != null) values;
  in
    if matches == []
    then null
    else builtins.head matches;

  t3codePackage = firstNonNull [(darwinCaskOrNull "t3-code") (hostPackageOrNull "t3code")];
  antigravityPackage = firstNonNull [(darwinCaskOrNull "antigravity") (hostPackageOrNull "antigravity")];
  rawHandyPackage = firstNonNull [(darwinCaskOrNull "handy") (flakePackageOrNull "handy") (hostPackageOrNull "handy")];
  chatgptPackage = darwinCaskOrNull "chatgpt";
  claudeDesktopPackage = firstNonNull [(darwinCaskOrNull "claude") (flakePackageOrNull "claude-desktop")];

  handyPackage =
    if rawHandyPackage != null && pkgs.stdenv.isDarwin && rawHandyPackage ? override
    then rawHandyPackage.override {variation = "tahoe";}
    else rawHandyPackage;

  withoutBins = package:
    if !(package ? overrideAttrs)
    then package
    else
      package.overrideAttrs (oldAttrs:
        if oldAttrs ? installPhase
        then {
          installPhase =
            oldAttrs.installPhase
            + ''
              rm -rf $out/bin
            '';
        }
        else {
          postInstall =
            (oldAttrs.postInstall or "")
            + ''
              rm -rf $out/bin
            '';
        });
in {
  ## GUI apps use brew-nix casks on Darwin and native package attrs on Linux.
  ## The standalone `#ai` CLI shell disables this so it stays lean.
  options.aiNixCfg.guiApps.enable =
    mkEnableOption "GUI applications (Antigravity, handy, Claude Desktop, …)"
    // {default = true;};

  config = mkIf config.aiNixCfg.guiApps.enable (mkMerge [
    (mkIf (t3codePackage != null) {
      programs.t3code = {
        enable = false;
        package = t3codePackage;
        mutableUserSettings = true;
        mutableKeybindings = true;
        mutableClientSettings = true;
      };
    })

    (mkIf (antigravityPackage != null) {
      programs.antigravity = {
        enable = false;
        package = antigravityPackage;
        mutableExtensionsDir = true;
        profiles.default = {
          enableMcpIntegration = true;
        };
      };
    })

    {
      home.packages =
        optional (handyPackage != null) handyPackage
        ++ optional (chatgptPackage != null) chatgptPackage
        ++ optional (claudeDesktopPackage != null) (withoutBins claudeDesktopPackage);
    }
  ]);
}

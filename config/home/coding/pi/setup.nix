{
  config,
  pkgs,
  lib,
  ...
}: let
  # Preserve platform coverage for the existing extension and LSP bundle.
  hasLegacyPiBundle =
    (pkgs.stdenvNoCC.hostPlatform.isDarwin
      || pkgs.stdenvNoCC.hostPlatform.isLinux)
    && pkgs.stdenvNoCC.hostPlatform.system != "x86_64-darwin";
  # Match the platforms on which coding/misc.nix installs pi-rust.
  hasPiRust = lib.elem pkgs.stdenvNoCC.hostPlatform.system [
    "aarch64-darwin"
    "x86_64-linux"
    "x86_64-darwin"
  ];

  # pi-grok uses the TypeScript host's Pi SDK as peer dependencies.
  # Keep it out of the auto-discovered agent directory shared with pi-rust.
  piGrok = pkgs.fetchFromGitHub {
    name = "pi-grok-0.13.1";
    owner = "stnly";
    repo = "pi-grok";
    rev = "dd0121416d830a0ebd7dc19aa27cf4d754b6061a"; # v0.13.1
    hash = "sha256-0I03wQ8HWD18KsGxw6xhauOb1JSomsLkomwOKRPYjQ4=";
  };

  # Pinned to the same rev that was tracked as the coding-agents flake input.
  # Update by bumping rev + running `nix build` to get the new hash from the
  # mismatch error, then copying it here.
  piExtSrc = pkgs.fetchFromGitHub {
    owner = "kissgyorgy";
    repo = "coding-agents";
    rev = "4d8c448033ca332b55e79de4cbd0737da5c5cfda";
    hash = "sha256-gd0D8UwIMowFZgKD/OlL4xrdBOnJmZrlzIGa62ywixY=";
  };

  piExtensionsDir = "${piExtSrc}/home-manager/pi-coding-agent/extensions";

  # Hardcoded so Nix doesn't need to read the store path at eval time (IFD).
  # Update this list whenever the upstream extensions directory changes.
  otherExtNames = [
    "bash-blacklist"
    "codex-fast.ts"
    "continue-turn"
    "explorer-mode"
    "ext-dev.ts"
    "git-diff"
    "lsp"
    "plan-mode"
    "post-edit"
    "question.ts"
    "reload-shortcut"
    "systemprompt.ts"
    "tmux-mirror"
    "tps-tracker.ts"
    "web-search"
  ];

  # The fetch extension needs external npm deps (@mozilla/readability, jsdom,
  # turndown, unpdf) that pi's own node_modules don't include. buildNpmPackage
  # installs them alongside the source so jiti can resolve them at runtime.
  piFetchSrc = pkgs.runCommand "pi-fetch-ext-src" {} ''
    mkdir -p "$out"
    cp -rT "${piExtSrc}/home-manager/pi-coding-agent/extensions/fetch" "$out"
  '';

  piFetchExt = pkgs.buildNpmPackage {
    pname = "pi-fetch-extension";
    version = "0";
    src = piFetchSrc;
    # Obtain by running: nix build .#homeConfigurations.<name>.activationPackage
    # and copying the "got: sha256-..." value from the hash mismatch error.
    npmDepsHash = "sha256-fE2LKA2iVWI9KOXOuOWv7ttDaI5sDrE1ArI7jYDE+f4=";
    dontNpmBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp index.ts "$out/"
      cp -r node_modules "$out/"
      runHook postInstall
    '';
  };
in {
  home.file.".pi/agent/keybindings.json".source = lib.mkIf hasPiRust (
    (pkgs.formats.json {}).generate "pi-rust-keybindings.json" {
      # Pi Rust 0.8 has page actions, not configurable line scrolling.
      # Preserve both built-in paging shortcuts, and move dequeue out of the way.
      pageUp = ["pageup" "shift+up" "alt+up"];
      pageDown = ["pagedown" "shift+down" "alt+down"];
      dequeue = "alt+shift+up";
      # Leave cursor and picker defaults alone. Ctrl+G uses $VISUAL/$EDITOR
      # for modal editing (including Vim-Cfg's U/R), not bare composer keys.
    }
  );

  programs.pi.coding-agent = {
    enable = lib.mkDefault (hasLegacyPiBundle && config.aiCoding.installArchivedTools);
    extensions =
      ["${piGrok}/index.ts"]
      ++ lib.optionals hasLegacyPiBundle (
        ["${piFetchExt}/index.ts"]
        ++ map (n: "${piExtensionsDir}/${n}") otherExtNames
      );
  };

  home.packages = lib.optionals hasLegacyPiBundle (
    [
      pkgs.nil
      pkgs.basedpyright
      pkgs.typescript-language-server
      pkgs.typescript
      pkgs.gopls
      pkgs.go
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.wl-clipboard
    ]
  );
}

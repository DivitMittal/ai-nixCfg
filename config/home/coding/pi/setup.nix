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

  # The full extension remains exclusive to the TypeScript host. Pi Rust 0.9
  # lacks pi-tui.getKeybindings and drops callback-based OAuth registration.
  # Its native Responses transport can nevertheless run the upstream token
  # bypass, model catalog and payload sanitizer without the incompatible UI.
  piGrok = pkgs.fetchFromGitHub {
    name = "pi-grok-0.13.1";
    owner = "stnly";
    repo = "pi-grok";
    rev = "dd0121416d830a0ebd7dc19aa27cf4d754b6061a"; # v0.13.1
    hash = "sha256-0I03wQ8HWD18KsGxw6xhauOb1JSomsLkomwOKRPYjQ4=";
  };

  piRustGrokEntry = pkgs.writeText "pi-grok-rust.ts" ''
    import { resolveModels, CLI_PROXY_BASE_URL, buildProxyHeaders } from "${piGrok}/models.ts";
    import { sanitizePayload } from "${piGrok}/sanitize.ts";

    export default function (pi) {
      // ~/.pi/agent is shared with TypeScript Pi. Never override its full
      // pi-grok provider when this auto-discovered adapter loads there.
      if (process.release?.lts !== "PiJS") return;
      const baseUrl = process.env.PI_XAI_OAUTH_BASE_URL || CLI_PROXY_BASE_URL;
      pi.registerProvider("xai-oauth", {
        name: "xAI (SuperGrok token, Pi Rust)",
        baseUrl,
        api: "openai-responses",
        models: resolveModels().map(model => ({
          ...model,
          baseUrl,
          headers: buildProxyHeaders(model.id),
        })),
        // Deliberately omit streamSimple: Rust's native transport streams
        // directly. The virtual SDK bridge is not the upstream Node streamer.
      });
      pi.on("before_provider_request", (event, ctx) => {
        if (ctx.model?.provider !== "xai-oauth") return;
        return sanitizePayload(
          event.payload, ctx.model.id, ctx.sessionManager?.getSessionId(),
          ctx.model.reasoning ?? false,
        );
      });
    }
  '';

  piRustGrok = pkgs.runCommand "pi-grok-rust" {nativeBuildInputs = [pkgs.bun];} ''
    bun build ${piRustGrokEntry} --target=node --packages=external --format=esm --outfile="$out/index.js"
    mv "$out/index.js" "$out/index.ts"
  '';

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

  # Pi Durable subagents: crash-safe, resumable background subagents built on
  # @earendil-works/pi-durable. The npm tarball ships prebuilt dist/ and only
  # peer-depends on pi packages, which the TypeScript Pi host provides. It is
  # not loaded into Pi Rust (no pi-tui/coding-agent module bridge there).
  piDurableSubagents = pkgs.fetchzip {
    name = "pi-durable-subagents-1.7.0";
    url = "https://registry.npmjs.org/pi-durable-subagents/-/pi-durable-subagents-1.7.0.tgz";
    hash = "sha256-SgGEkC22cZc2Uuy83t9Sf6hsThXyKtEXFTTNa6uwKo8=";
  };

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
  home.file.".pi/agent/extensions/pi-grok-rust" = lib.mkIf hasPiRust {
    source = piRustGrok;
  };
  home.file.".pi/agent/pi-grok-rust.md" = lib.mkIf hasPiRust {
    text = ''
      # SuperGrok in Pi Rust

      The Rust adapter uses pi-grok 0.13.1's model definitions, proxy identity
      headers and Responses payload sanitizer with Rust's native streaming.
      Add this entry to Pi Rust's auth.json (merge it with any existing entries):

      ```json
      {"xai-oauth":{"type":"api_key","key":"$ENV:XAI_OAUTH_TOKEN"}}
      ```

      Then supply an existing subscription access token at runtime:

      ```sh
      export XAI_OAUTH_TOKEN='your-access-token'
      pi-rust --provider xai-oauth --model grok-4.6
      ```

      Never put the token in Nix configuration or the Nix store.
      You can use the full TypeScript host without enabling it in Home Manager:

      ```sh
      PI_CODING_AGENT_DIR="$HOME/.local/share/pi-grok-login" bunx -p @earendil-works/pi-coding-agent@1.3.0 pi install git:github.com/stnly/pi-grok@v0.13.1
      PI_CODING_AGENT_DIR="$HOME/.local/share/pi-grok-login" bunx -p @earendil-works/pi-coding-agent@1.3.0 pi
      ```

      Run `/login` there. Token expiry requires a fresh token and restarting
      pi-rust. PI_XAI_OAUTH_MODELS filters models
      using upstream semantics. PI_XAI_CLIENT_VERSION overrides the upstream
      cached proxy client version. PI_XAI_OAUTH_BASE_URL optionally overrides
      the proxy endpoint, so only point it at a trusted server.

      Pi Rust 0.9 does not implement pi-grok's callback-based /login, refreshToken
      or modifyModels. This adapter does not provide automatic refresh, live
      model discovery, x_search, account/privacy commands or the Node streamer's
      per-request conversation headers. The full upstream extension remains
      available when opting into programs.pi.coding-agent.enable for TypeScript
      Pi, but must not be loaded into Rust. Switching tokens/client versions
      requires restarting Rust. Real subscription access needs valid credentials
      and has not been verified by the offline integration test.
    '';
  };

  home.file.".pi/agent/keybindings.json" = lib.mkIf hasPiRust {
    source = (pkgs.formats.json {}).generate "pi-rust-keybindings.json" {
      # Pi Rust 0.8 has page actions, not configurable line scrolling.
      # Preserve both built-in paging shortcuts, and move dequeue out of the way.
      pageUp = ["pageup" "shift+up" "alt+up"];
      pageDown = ["pagedown" "shift+down" "alt+down"];
      dequeue = "alt+shift+up";
      # Leave cursor and picker defaults alone. Ctrl+G uses $VISUAL/$EDITOR
      # for modal editing (including Vim-Cfg's U/R), not bare composer keys.
    };
  };

  programs.pi.coding-agent = {
    enable = lib.mkDefault (hasLegacyPiBundle && config.aiCoding.installArchivedTools);
    extensions =
      ["${piGrok}/index.ts" "${piDurableSubagents}/index.js"]
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

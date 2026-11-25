## Eval-time tests for the home-manager modules and the composed config.
##
## CI only evaluated the `ai` app, which disables voice/Talon, and never
## imported the exported standalone modules on their own. These checks
## evaluate both, and pin module behaviour (generated files, env wiring,
## assertions) with lib.debug.runTests. Nothing is built: drvPaths are taken
## with their string context discarded.
{
  inputs,
  self,
  ...
}: {
  perSystem = {system, ...}: let
    nixpkgsInput =
      if system == "x86_64-darwin"
      then inputs."nixpkgs-2605"
      else inputs.nixpkgs;
    pkgs = import nixpkgsInput {
      inherit system;
      config.allowUnfree = true;
    };
    inherit (pkgs) lib;
    inherit (pkgs.stdenv) isDarwin isLinux;

    base = {
      home.username = "test";
      home.homeDirectory =
        if isDarwin
        then "/Users/test"
        else "/home/test";
      home.stateVersion = "25.05";
    };

    hm = modules:
      (inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs lib;
        extraSpecialArgs = {inherit inputs;};
        modules = [base] ++ modules;
      }).config;

    ## A module on its own, the way a consumer imports it.
    standaloneModules = module: extra: [
      {_module.args.ai-nixCfg = self;}
      module
      extra
    ];
    standalone = module: extra: hm (standaloneModules module extra);
    ## homeManagerConfiguration throws on any failed assertion, so assertion
    ## tests evaluate HM's module list directly, as its modules/default.nix does.
    hmLib = import "${inputs.home-manager}/modules/lib/stdlib-extended.nix" lib;
    rawEval = modules:
      hmLib.evalModules {
        modules =
          [base]
          ++ modules
          ++ import "${inputs.home-manager}/modules/modules.nix" {
            inherit pkgs;
            lib = hmLib;
            check = true;
          };
        class = "homeManager";
        specialArgs = {
          inherit inputs;
          modulesPath = "${inputs.home-manager}/modules";
        };
      };
    failedAssertions = module: extra:
      map (a: a.message) (lib.filter (a: !a.assertion) (rawEval (standaloneModules module extra)).config.assertions);
    evaluates = cfg: builtins.unsafeDiscardStringContext cfg.home.activationPackage.drvPath != "";

    m = self.homeManagerModules;
    proxyCfg = extra: {programs.cliproxyapi = {enable = true;} // extra;};
    proxy = extra: standalone ../modules/home/cliproxyapi.nix (proxyCfg extra);
    proxyFailures = extra: failedAssertions ../modules/home/cliproxyapi.nix (proxyCfg extra);
    xdg = cfg: cfg.xdg.configHome;
    composed = extra:
      hm [
        {
          aiNixCfg.guiApps.enable = false; # needs the consumer's brew-nix overlay
          aiNixCfg.voice.installDarwinApps = false; # ditto
          home.sessionVariables.EDITOR = "vim";
        }
        self.homeManagerConfigurations.default
        extra
      ];

    piRustSupported = lib.elem system ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];
    piFiles = (composed {}).home.file;

    tests = {
      ## ---- composed config -------------------------------------------------
      testFullConfigEvaluates = {
        expr = evaluates (composed {});
        expected = true;
      };

      testMcpcInHomePackages = {
        expr = map (pkg: pkg.name) (lib.filter (pkg: lib.getName pkg == "mcpc") (composed {}).home.packages);
        expected = [
          (
            if pkgs ? mcpc && lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.mcpc
            then pkgs.mcpc.name
            else "mcpc"
          )
        ];
      };

      testVoiceManagesTalonFiles = {
        expr = let
          cfg = composed {};
          userDir = cfg.programs.talon.userDir;
          smokeTest = cfg.home.file."${userDir}/custom/ai-nixCfg.talon".source;
        in
          cfg.programs.talon.enable
          && cfg.home.file ? "${userDir}/community"
          && builtins.readFile smokeTest == builtins.readFile ../config/home/voice/talon/ai-nixCfg.talon;
        expected = true;
      };

      testPiGrokWithStandalonePiOptIn = {
        expr = let
          piEnabled = extra:
            (composed extra).programs.pi.coding-agent;
          cfg = piEnabled {programs.pi.coding-agent.enable = true;};
        in {
          defaultEnabled = (piEnabled {}).enable;
          optedIn = cfg.enable;
          hasGrok = lib.any (lib.hasSuffix "-pi-grok-0.13.1/index.ts") cfg.extensions;
        };
        expected = {
          defaultEnabled = false;
          optedIn = true;
          hasGrok = true;
        };
      };

      testAntigravityCliEnabled = {
        expr = let
          cfg = (composed {}).programs.antigravity-cli;
        in
          cfg.enable && cfg.package.meta.mainProgram == "agy";
        expected = true;
      };

      testPiRustGrokInstalledSeparately = {
        expr = {
          adapter = piFiles ? ".pi/agent/extensions/pi-grok-rust";
          documentation = piFiles ? ".pi/agent/pi-grok-rust.md";
          typescriptDisabled = !(composed {}).programs.pi.coding-agent.enable;
        };
        expected = {
          adapter = piRustSupported;
          documentation = piRustSupported;
          typescriptDisabled = true;
        };
      };

      ## ---- exported standalone modules ------------------------------------
      testCodexStandalone = {
        expr = evaluates (standalone m.codex {programs.codex.enable = true;});
        expected = true;
      };
      testCrushStandalone = {
        expr = evaluates (standalone m.crush {programs.crush.enable = true;});
        expected = true;
      };
      testN8nStandalone = {
        expr = evaluates (standalone m.n8n {
          programs.n8n.enable = true;
          programs.n8n.service.enable = false;
        });
        expected = true;
      };

      ## ---- cliproxyapi ------------------------------------------------------
      testProxyBindsLocalhostByDefault = {
        expr = (proxy {}).programs.cliproxyapi.settings.host;
        expected = "127.0.0.1";
      };
      testProxyOpenAIClientEnv = {
        expr = let
          cfg = proxy {
            settings.api-keys = ["k"];
            clients.openai = true;
          };
        in {
          inherit (cfg.home.sessionVariables) OPENAI_BASE_URL OPENAI_API_KEY;
        };
        expected = {
          OPENAI_BASE_URL = "http://127.0.0.1:8317/v1";
          OPENAI_API_KEY = "k";
        };
      };
      testProxyEndpointFollowsPort = {
        expr = (proxy {settings.port = 9000;}).programs.cliproxyapi.endpoint;
        expected = "http://127.0.0.1:9000";
      };
      testProxyClientsNeedApiKey = {
        expr = proxyFailures {clients.claudeCode = true;};
        expected = ["programs.cliproxyapi.clients requires a non-empty string in programs.cliproxyapi.settings.api-keys."];
      };
      testProxyClientsNeedService = {
        expr = proxyFailures {
          settings.api-keys = ["k"];
          clients.openai = true;
          service.enable = false;
        };
        expected = ["programs.cliproxyapi.clients.* point at the local proxy, which needs programs.cliproxyapi.service.enable."];
      };
      testProxyServiceNeedsPackage = {
        expr = proxyFailures {package = null;};
        expected = ["programs.cliproxyapi.service.enable requires programs.cliproxyapi.package to be non-null."];
      };
      testProxyServiceMatchesPlatform = {
        expr = let
          cfg = proxy {};
        in {
          launchd = cfg.launchd.agents ? cliproxyapi && cfg.launchd.agents.cliproxyapi.enable;
          systemd = cfg.systemd.user.services ? cliproxyapi;
        };
        expected = {
          launchd = isDarwin;
          systemd = isLinux;
        };
      };
      testProxyMutableConfigIsMerged = {
        expr = let
          cfg = proxy {settings.port = 8317;};
        in {
          activation = cfg.home.activation ? cliproxyapiSettingsActivation;
          linked = cfg.xdg.configFile ? "cliproxyapi/config.yaml";
        };
        expected = {
          activation = true;
          linked = false;
        };
      };
      testProxyImmutableConfigIsLinked = {
        expr = let
          cfg = proxy {
            mutableUserSettings = false;
            settings.port = 8317;
          };
        in {
          activation = cfg.home.activation ? cliproxyapiSettingsActivation;
          linked = cfg.xdg.configFile."cliproxyapi/config.yaml".enable;
        };
        expected = {
          activation = false;
          linked = true;
        };
      };

      ## ---- codex / crush / n8n ---------------------------------------------
      testCodexRejectsReservedPetName = {
        expr = failedAssertions m.codex {
          programs.codex.enable = true;
          programs.codex.pets.disabled = {spritesheet = pkgs.emptyFile;};
        };
        expected = ["Codex pet names must use letters, digits, underscores or hyphens, and cannot be 'disabled'."];
      };
      testCodexPromptsBecomeFiles = {
        expr = let
          cfg = standalone m.codex {
            programs.codex.enable = true;
            programs.codex.prompts.review = "Review the diff.";
          };
        in
          cfg.xdg.configFile."codex/prompts/review.md".text;
        expected = "Review the diff.";
      };
      testCrushCommandsBecomeFiles = {
        expr = let
          cfg = standalone m.crush {
            programs.crush.enable = true;
            programs.crush.commands.fix = "---\ndescription: fix\n---\nFix it.";
          };
        in
          cfg.home.file."${xdg cfg}/crush/commands/fix.md".text;
        expected = "---\ndescription: fix\n---\nFix it.";
      };
      testN8nServiceIsLinuxOnly = {
        expr =
          failedAssertions m.n8n {
            programs.n8n.enable = true;
            programs.n8n.service.enable = true;
          }
          == [];
        expected = isLinux;
      };
    };

    failures = lib.debug.runTests tests;

    ## Rendered crush.json, checked with jq: the file other tools actually read.
    crushJson =
      (standalone m.crush {
        programs.crush.enable = true;
        programs.crush.mcp.fs = {
          type = "stdio";
          command = "mcp-fs";
          args = ["--root" "/tmp"];
        };
      }).home.file;
  in {
    checks.module-tests =
      pkgs.runCommand "ai-nixCfg-module-tests" {
        passAsFile = ["report"];
        report =
          if failures == []
          then "all ${toString (lib.length (lib.attrNames tests))} module tests passed"
          else builtins.toJSON failures;
      } ''
        cat "$reportPath"; echo
        ${lib.optionalString (failures != []) "exit 1"}
        touch $out
      '';

    # Exercise the shipped auto-discovered adapter with the packaged Rust
    # runtime, not doctor (which misses unsupported named SDK exports).
    checks.pi-grok-rust = lib.mkIf piRustSupported (
      pkgs.runCommand "ai-nixCfg-pi-grok-rust" {
        nativeBuildInputs = [pkgs.python3];
        __darwinAllowLocalNetworking = true;
        pi = "${self.packages.${system}.pi-agent-rust}/bin/pi-rust";
        adapter = piFiles.".pi/agent/extensions/pi-grok-rust".source;
      } ''
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME/.pi/agent/extensions"
        ln -s "$adapter" "$HOME/.pi/agent/extensions/pi-grok-rust"
        export PI_CODING_AGENT_DIR="$HOME/.pi/agent"
        printf '%s\n' '{"xai-oauth":{"type":"api_key","key":"$ENV:XAI_OAUTH_TOKEN"}}' > "$PI_CODING_AGENT_DIR/auth.json"
        chmod 600 "$PI_CODING_AGENT_DIR/auth.json"
        export PI_XAI_CLIENT_VERSION=1.0.46
        export PI_XAI_OAUTH_MODELS=grok-4.6
        export PI_WORKSPACE_TRUST=untrusted
        python3 - <<'PY'
        import http.server
        import json
        import os
        import subprocess
        import threading

        requests = []

        class Handler(http.server.BaseHTTPRequestHandler):
            def log_message(self, *args):
                pass

            def do_POST(self):
                payload = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
                requests.append((self.path, dict(self.headers), payload))
                events = [
                    {"type": "response.created", "response": {"id": "resp_test"}},
                    {"type": "response.output_item.added", "output_index": 0,
                     "item": {"type": "message", "id": "msg_1", "role": "assistant", "content": []}},
                    {"type": "response.output_text.delta", "item_id": "msg_1",
                     "content_index": 0, "delta": "GROK_ADAPTER_OK"},
                    {"type": "response.completed", "response": {"id": "resp_test",
                     "status": "completed", "incomplete_details": None,
                     "usage": {"input_tokens": 1, "output_tokens": 1, "total_tokens": 2}}},
                ]
                body = "".join("data: " + json.dumps(event) + "\n\n" for event in events).encode()
                self.send_response(200)
                self.send_header("Content-Type", "text/event-stream")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

        server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        env = dict(os.environ, PI_XAI_OAUTH_BASE_URL=f"http://127.0.0.1:{server.server_port}/v1")
        command = [env["pi"], "--no-session", "--no-migrations", "--no-skills",
                   "--no-prompt-templates", "--provider", "xai-oauth", "--model", "grok-4.6",
                   "--thinking", "off", "-p", "Reply with the test marker."]
        try:
            # No token must fail locally, not send a literal "$ENV" credential.
            env.pop("XAI_OAUTH_TOKEN", None)
            missing = subprocess.run(command, env=env, text=True, capture_output=True, timeout=30)
            assert missing.returncode != 0, missing
            assert "No API key found for provider xai-oauth" in missing.stderr, missing.stderr
            assert not requests, requests

            env["XAI_OAUTH_TOKEN"] = "pi-grok-integration-test-token"
            result = subprocess.run(command, env=env, text=True, capture_output=True, timeout=30)
            assert result.returncode == 0, (result.stdout, result.stderr)
            assert "GROK_ADAPTER_OK" in result.stdout, (result.stdout, result.stderr)
            assert len(requests) == 1, requests
            path, headers, payload = requests[0]
            headers = {key.lower(): value for key, value in headers.items()}
            assert path == "/v1/responses", path
            assert headers["authorization"] == "Bearer pi-grok-integration-test-token", headers
            assert headers["x-xai-token-auth"] == "xai-grok-cli", headers
            assert headers["x-grok-model-override"] == "grok-4.6", headers
            assert headers["x-grok-client-version"] == "1.0.46", headers
            assert payload["model"] == "grok-4.6", payload
            # Upstream sanitizer lifts system/developer messages to instructions.
            assert payload.get("instructions"), payload
            assert all(item.get("role") not in ("system", "developer") for item in payload["input"]), payload
            print("Pi Rust Grok: auto-discovery, missing token, auth/identity headers, sanitizer and SSE passed")
        finally:
            server.shutdown()
        PY
        touch "$out"
      ''
    );

    checks.crush-config =
      pkgs.runCommand "ai-nixCfg-crush-config" {
        nativeBuildInputs = [pkgs.jq];
        json = (lib.findFirst (f: lib.hasSuffix "crush/crush.json" f.target) null (lib.attrValues crushJson)).source;
      } ''
        jq -e '."$schema" == "https://charm.land/crush.json"' "$json"
        jq -e '.mcp.fs | .type == "stdio" and .command == "mcp-fs" and .args == ["--root","/tmp"]' "$json"
        jq -e '[.. | select(. == null)] | length == 0' "$json"
        touch $out
      '';
  };
}

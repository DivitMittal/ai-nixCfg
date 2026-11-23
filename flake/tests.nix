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

    tests = {
      ## ---- composed config -------------------------------------------------
      testFullConfigEvaluates = {
        expr = evaluates (hm [
          {
            aiNixCfg.guiApps.enable = false; # needs the consumer's brew-nix overlay
            aiNixCfg.voice.installDarwinApps = false; # ditto
            home.sessionVariables.EDITOR = "vim";
          }
          self.homeManagerConfigurations.default
        ]);
        expected = true;
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

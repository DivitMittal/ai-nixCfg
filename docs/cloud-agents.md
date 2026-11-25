# Cloud coding agents

Use the same pinned Linux tools and shared agent content on Codex Cloud, Claude Code cloud sessions, and Cursor Cloud Agents. Each provider manages its own environment, credentials, and task lifecycle. The bootstrap runs during provisioning and uses a single-user Nix store when the worker has no existing Nix. It requires Bash, standard GNU utilities, and either usable Nix or permission to create and write `/nix`. The tools and configs come from this flake. The provider supplies the agent harness.

## Select and distribute a revision

Commit and push your changes to `DivitMittal/ai-nixCfg`. Run the following from a checkout containing that commit. Set `TARGET` to an absolute checkout path for your project.

```bash
REV=$(git rev-parse HEAD)
REF="github:DivitMittal/ai-nixCfg/$REV"
TARGET=/path/to/project
CONFIG=$(nix build --no-link --print-out-paths "$REF#cloud-agent-config")
STAGE=$(mktemp -d)

# Render the setup used in each provider UI or tracked project wrapper.
bash cloud/render-setup.sh codex "$REV" core > "$STAGE/codex-setup.sh"
bash cloud/render-setup.sh claude "$REV" core > "$STAGE/claude-setup.sh"
bash cloud/render-setup.sh cursor "$REV" core > "$STAGE/cursor-setup.sh"

# Dereference Nix store links when preparing files for another repository.
for provider in codex claude cursor; do
  mkdir -p "$STAGE/$provider"
  cp -RL "$CONFIG/$provider/." "$STAGE/$provider/"
done
```

Review and copy the staged files into the project. Merge existing files and commit the resulting project configuration on the branch your provider will use. The Codex guidance belongs in the root `AGENTS.md`, and its skills belong in `.agents/skills/`. For Claude, merge `.claude/settings.json` by appending the generated `SessionStart` hook and unioning the deny entries with the project's existing permissions. Its `.claude/` tree also includes rules, skills, agent definitions, and commands. For Cursor, commit `.cursor/rules/` and `.cursor/skills/`. If several harnesses read overlapping skill roots, keep one copy of each skill per harness's discovery rules.

The generated scripts include the bootstrap from the exact Git commit, so the setup field itself needs no network access to download shell code. By default it builds the locked flake directly from GitHub. The worker needs access to GitHub's API and source endpoints, `cache.nixos.org`, and `releases.nixos.org` for the Nix installer if necessary. Keep setup egress limited to the required hosts and any project dependencies. Build failures name the GitHub/cache path and suggest the closure path.

### Prebuild when source access is restricted

For Claude in particular, GitHub's repository proxy can deny source archive requests for repositories outside the session. Nested flake inputs also live in separate repositories. Build and export the exact profile on a Linux machine or an ephemeral CI runner of the worker's architecture, then upload the archive to an approved HTTPS artifact host. No persistent builder is needed. The artifact host must support an unattended download and its URL must contain no credentials.

```bash
# On Linux with Bash, Nix and flakes enabled.
bash cloud/export-closure.sh "$REV" core "ai-nixcfg-$REV-core-x86_64-linux.gz"
# Upload the file to the approved host and copy the SHA-256 printed above.
ARTIFACT_URL="https://artifacts.example.org/ai-nixcfg-$REV-core-x86_64-linux.gz"
SHA256="PASTE_THE_HEX_DIGEST_HERE"
bash cloud/render-setup.sh claude "$REV" core "$ARTIFACT_URL" "$SHA256" > "$STAGE/claude-setup.sh"
```

Use the same arguments with `codex` or `cursor` if needed. The closure contains the built toolchain and rendered config. The bootstrap checks the digest and revision, profile, and architecture before importing. A trusted Nix store is required to import a locally built closure. If an existing daemon rejects unsigned paths, use direct flake provisioning or publish through an approved signed binary cache. Use a new digest and URL for each release. An absolute local file path can replace the HTTPS URL when the provider already stages the checksummed closure. With a usable Nix install, that path works offline. A blocked artifact host or missing store permissions fails setup explicitly. In that case you can still ship the project config and use the provider's own package and runtime setup, with versions and capabilities governed by that provider.

## Profiles and shell environment

| Output | Systems | Purpose |
| --- | --- | --- |
| `packages.<system>.cloud-agent-tools` | `x86_64-linux`, `aarch64-linux` | Core with Git, GitHub CLI, jq, yq, ripgrep, fd, Nix, and Alejandra |
| `packages.<system>.cloud-agent-tools-infra` | Same Linux systems | Core plus nil, nixd, OpenTofu, kubectl, Helm, and RTK |
| `packages.<system>.cloud-agent-config` | All flake systems | Project files staged from the current shared rules and provider generators |
| `devShells.<system>.agent-cloud` | Linux | Core tools for interactive Linux development |
| `checks.<system>.cloud-agents` | All flake systems | ShellCheck, config validation, and controlled bootstrap tests |

The worker stores profiles under `$HOME/.local/state/ai-nixcfg-cloud`. Setup and tasks must run with the same `HOME` and a store the task can access. The `current` link switches only after verification. Re-running the same pin uses the installed generation and verifies it offline. Keep the core profile for fast setup and choose `infra` explicitly if the project needs those tools.

Run commands in Bash and source the installed environment in the task shell. An export inside a provisioning subprocess only lasts for that subprocess. Codex and Cursor setup add an idempotent entry for interactive Bash shells that read a regular `~/.bashrc`. For noninteractive shells, source the env file explicitly or configure `BASH_ENV` when the provider supports it. Claude's project hook uses `CLAUDE_ENV_FILE` to load it automatically in supported sessions.

```bash
source "$HOME/.local/state/ai-nixcfg-cloud/env"
gh --version
nix --version
```

The bootstrap can use existing Nix without elevated privileges. On an empty worker it uses the official checksummed single-user distribution and creates `/nix` only as root or with noninteractive sudo. A local single-user store uses no daemon or Nix build sandbox. Keep this mode inside the disposable provider worker. The single-user installer warns on root, which is the account Claude uses for setup. Rootless tools such as Nix Portable rely on user namespaces or ptrace and change how commands are launched. This integration treats workers without a usable store or writable `/nix` as unsupported, with Cursor's Dockerfile option available to prepare a suitable base. [Nix installation manual](https://nix.dev/manual/nix/2.19/installation/installing-binary) · [Nix Portable implementation](https://github.com/DavHau/nix-portable)

## Codex Cloud

1. In ChatGPT web or desktop choose **Work in → Cloud → Select environment → Create environment**, or open **Settings → Codex Cloud → Environments**. Connect GitHub and grant access to the project repositories.
1. In the setup conversation provide the contents of `codex-setup.sh` and ask Codex to use it as the **Install script**. For a long-lived environment, you can instead commit it under a project-owned path and have the install script run that file from the checked-out repository. Ask the **Start skill** to source the installed Bash environment for terminal commands and to run the smoke check below. Keep any project-specific install commands after the bootstrap, in a shell that sources the environment.
1. Review the setup report and run the smoke check during preparation. **Publish** the prepared environment, then repeat the smoke check in a new task. For updates, select **Edit**, supply the new script or project source, prepare and test, then select **Republish**. Repository refresh alone preserves caches and does not rerun installation. Existing tasks keep their own state.
1. On web or mobile choose the published environment before starting a task. From the CLI, use the interactive picker to confirm your environment is visible. Use the web flow if your installed CLI or account does not expose that environment.

```bash
codex login
codex cloud
codex cloud exec --env "$ENV_ID" "Run the tests and fix the failing case"
codex cloud list --env "$ENV_ID"
codex apply "$TASK_ID"
```

Inspect the diff in the task before applying it to a clean checkout or use the provider UI to open a PR. For a **Legacy** environment, paste the rendered script as manual **Setup script** and optionally run it as **Maintenance script** if you need to verify warmed workers or run branch-sensitive setup. Legacy caches prepared containers for up to 12 hours, and script changes or **Reset cache** refresh the cache. Use the verified shell activation command in the task or set Bash's `BASH_ENV` to the absolute env file path if you control that variable and are preserving any existing provider startup behavior. [Current cloud environments](https://learn.chatgpt.com/docs/environments/cloud-environments) · [Legacy environments](https://learn.chatgpt.com/docs/environments/cloud-environment) · [CLI commands](https://learn.chatgpt.com/docs/developer-commands)

## Claude Code cloud sessions

1. In Claude Code on the web, authorize the **Claude GitHub App** for the project. Use the environment selector to add or edit a cloud environment, open **Setup script**, and paste or upload `claude-setup.sh`. Set network access for the Nix release host and closure host when using an artifact. In setup, put the pin and artifact parameters in the script itself, as session environment variables arrive later.
1. Select that environment when starting a web session. For CLI dispatch, open the Claude TUI and choose it with `/remote-env`. The `--environment` flag only accepts self-hosted environment IDs. For a single-repository session, commit the generated `.claude/` files. Setup prepares the VM before Claude starts. The project `SessionStart` hook runs on start or resume and only loads shell environment in cloud sessions. Existing application dependencies or services can use a separate repository hook.
1. Changing the setup script or allowed hosts invalidates the setup snapshot. Start a fresh session after changing the pin. Snapshots are reused when setup completes in roughly five minutes, expire after roughly seven days, and preserve files rather than running processes. Project threads and multi-repository sessions can ignore project permission settings and hooks, so source the environment explicitly and use the provider's managed policies there.

```bash
# Push your branch before dispatch so the cloud checkout has the expected files.
claude --cloud "Run the tests and fix the failing case"
# Watch or continue on claude.ai/code or in the Claude mobile app.
# Use /teleport in the cloud session to get the exact session ID.
claude --teleport "$SESSION_ID"
```

Teleport from a clean checkout of the same repository while signed in to the same account. The session branch must be pushed for checkout. The older `--remote` spelling is a deprecated alias. `/web-setup` can authorize through a locally stored `gh` credential when appropriate, but the App is the preferred repository-scoped connection. [Cloud setup and caching](https://code.claude.com/docs/en/cloud-environments) · [Dispatch and Teleport](https://code.claude.com/docs/en/claude-code-on-the-web) · [Settings in cloud sessions](https://code.claude.com/docs/en/settings)

## Cursor Cloud Agents

1. Connect GitHub in the Cloud Agents dashboard and grant the Cursor GitHub App access to the project. Commit the environment configuration and generated setup script to the default branch. If the project already has an environment file, merge the `install` command and keep existing project settings.

   ```bash
   mkdir -p "$TARGET/.cursor"
   cp cloud/cursor-environment.json "$TARGET/.cursor/environment.json"
   cp "$STAGE/cursor-setup.sh" "$TARGET/.cursor/ai-nixcfg-setup.sh"
   ```

1. Use the dashboard to create or select the repository environment. Choose its committed environment file, review the build log, and run a smoke task against the active Build. The `install` command prepares the profile and verifies it during the Build. The active Build preserves disk state and uses the last successful Build if a refresh fails. After committing a new pin, trigger a Build on the environment's **Builds** tab and confirm the active Build has the new commit. Use `start` or `terminals` for project services that need to run per task.

1. If the install account has neither a usable Nix installation nor permission to create `/nix`, use a Dockerfile-based environment. Add `"build": {"dockerfile": "Dockerfile", "context": ".."}` beside `install` in `.cursor/environment.json`. In `.cursor/Dockerfile`, use a pinned Debian/Ubuntu base that meets Cursor's requirements and prepare a writable `/nix` for the image's actual runtime user, for example `RUN install -d -m 0755 -o ubuntu /nix` when your image already defines `ubuntu` as that user. Keep Bash, curl, CA certificates, xz, gzip, and util-linux available. The same install command runs on that base. Keep the Dockerfile independent of project source and use Cursor build secrets for any private base dependencies.

1. In the CLI launch `agent` in your project, then submit a message such as `& Run the tests and fix the failing case`. Monitor or resume at **cursor.com/agents** or on mobile, review changes, and open a PR or fetch the resulting branch with Git. You can also launch directly from the dashboard and select the environment or a specific Build there. [Environment setup](https://cursor.com/docs/cloud-agent/setup) · [Builds](https://cursor.com/docs/cloud-agent/builds) · [Dashboard settings](https://cursor.com/docs/cloud-agent/settings) · [CLI handoff](https://cursor.com/docs/cli/using)

## GitHub authentication and MCP

First use the provider connection for Git and PR operations. Installed `gh` uses any runtime credential the provider exposes. The bootstrap does not read, copy, print, or store credentials.

- **Codex**. Authorize the native GitHub connection and use the cloud UI for PRs. Check command-level GitHub API access independently. Current Codex Cloud supports host-scoped HTTP secrets. Use a scoped credential through that mechanism only if requests to `api.github.com` can use it in your environment. Legacy setup secrets disappear before the task, so they cannot provide task-time `GH_TOKEN`. [Codex environments](https://learn.chatgpt.com/docs/environments/cloud-environments) · [Legacy secret behavior](https://learn.chatgpt.com/docs/environments/cloud-environment)
- **Claude**. Leave `GH_TOKEN` and `GITHUB_TOKEN` unset in environment settings to use the GitHub proxy. Task commands may see the placeholder `proxy-injected`. Use `gh api` with an attached repository. The proxy can reject operations or requests outside its scope, even if native clone and push work. [Claude GitHub proxy](https://code.claude.com/docs/en/cloud-environments#github-proxy)
- **Cursor**. Use the GitHub App's per-agent Git and `gh` access. Its VM token cannot dispatch or rerun Actions workflows. If an operation explicitly requires broader access, Cursor documents setting a scoped `GH_TOKEN` via the provider's secret store. Prefer limiting it to the environment and repository that require it. Any runtime environment token is readable by task code. [Cursor GitHub authentication](https://cursor.com/docs/integrations/github) · [Cursor secrets](https://cursor.com/docs/cloud-agent/security-network)

Shared Git, security, and code-quality guidance ships as project files. Claude additionally gets native agents, commands, and the existing deny rules. The local Claude hooks expect environment payloads that differ from the documented hook JSON on stdin, so the cloud profile uses only the new SessionStart hook. Codex CLI prompts, local approval policies, and Cursor or Codex subagents have no verified equivalent here with the same semantics. Local proxies, account-specific settings, Herdr, and the APM checkout-specific Serena command stay outside the cloud bundle.

DeepWiki is the sole exported MCP endpoint. For Claude, merge `optional/claude/.mcp.json` into your trusted project config and approve the server as required. For Cursor, use the dashboard's Cloud MCP menu or a team-approved Cloud MCP server and use the URL from `optional/cursor/deepwiki.json`. Cloud agents apply the team's Cloud MCP and network controls. For Codex, use a provider-managed cloud tool if available. The bundle does not rely on local Codex TOML or inherited MCP servers. DeepWiki is a remote public service and optional, so network access or MCP initialization cannot block toolchain installation. Verify it separately by checking available MCP tools and requesting a read-only lookup of a public repository. [Claude hooks](https://code.claude.com/docs/en/hooks) · [Claude MCP](https://code.claude.com/docs/en/mcp) · [Cursor Cloud MCP](https://cursor.com/docs/cloud-agent/capabilities)

## Smoke test and troubleshooting

Start a task with the prepared environment and have it run this from a fresh shell. Substitute the actual provider name and commit SHA. Omit the repository argument to verify provisioning without network access.

```bash
source "$HOME/.local/state/ai-nixcfg-cloud/env"
bash "$HOME/.local/state/ai-nixcfg-cloud/current/smoke.sh" claude "$REV" OWNER/REPO
git status --short
```

Then ask the agent to show which instructions and skills it sees in the project and invoke the Nix flakes skill, which tests harness discovery beyond file presence. Review `gh auth status --hostname github.com` without `--show-token`, then use `gh api repos/OWNER/REPO --jq .full_name` with a scoped private repo if possible. A public metadata read can succeed anonymously. A successful metadata call also says nothing about Actions write access. If provider-native auth rejects the account-level probe, use the repo-scoped result.

For a failed installation, check architecture, filesystem permissions, setup egress, and that the selected Git revision is pushed or that the artifact's metadata matches. On source installations, cache misses may build derivations and exceed provider setup budgets. Use a prebuilt closure in that case. If install succeeded but the pinned tools are absent from PATH, check that the task sees the same home/store as the setup account and source the env file in that shell. Use a fresh session or Build to verify a new pin. Changes made during tasks live in the task workspace unless saved to a branch, pushed, or incorporated into a new environment publication.

To add a provider, use its documented install and task lifecycle with the existing bootstrap. Add a provider config tree in `cloud/config.nix` using the canonical generators, add its discovery paths to `cloud/smoke.sh`, and extend `cloud/test.py`. Grok Build's published interface is a terminal harness. The separate Grok Bot cloud product is outside these integrations. [Grok Build overview](https://docs.x.ai/build/overview)

#!/usr/bin/env node
// pi-durable: a minimal host for @earendil-works/pi-durable.
// One SQLite session per directory (or --session FILE). Every turn, tool call and
// answer is committed before it is shown, so a crashed run resumes on the next start.
//
//   pi-durable [-m provider/model] [-s session.sqlite] [--new] [prompt...]
//   pi-durable --resume            finish whatever the last process left unfinished
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, rmSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { parseArgs } from "node:util";
import { BACKGROUND_CONTEXT as context } from "@earendil-works/chord/context";
import { builtinModels } from "@earendil-works/pi-ai/providers/all";
import { AssistantEntry, createRegistry, defineExtension, Harness, section } from "@earendil-works/pi-durable";
import { NodeExecutionEnv } from "@earendil-works/pi-durable/env/node";
import { openNodeSqliteStorage } from "@earendil-works/pi-durable/storage/sqlite/node";
import { CodingTools } from "@earendil-works/pi-durable/tools";

// Reuse pi's default model from ~/.pi/agent/settings.json when present.
function piDefaultModel() {
  try {
    const dir = process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi/agent");
    const s = JSON.parse(readFileSync(join(dir, "settings.json"), "utf8"));
    return s.defaultProvider && s.defaultModel ? `${s.defaultProvider}/${s.defaultModel}` : undefined;
  } catch {
    return undefined;
  }
}

const { values, positionals } = parseArgs({
  allowPositionals: true,
  options: {
    model: { type: "string", short: "m", default: process.env.PI_DURABLE_MODEL ?? piDefaultModel() },
    session: { type: "string", short: "s" },
    new: { type: "boolean", default: false },
    resume: { type: "boolean", default: false },
    help: { type: "boolean", short: "h", default: false },
  },
});

if (values.help || (!values.resume && positionals.length === 0)) {
  console.log("usage: pi-durable [-m provider/model] [-s session.sqlite] [--new] <prompt...>\n       pi-durable --resume");
  process.exit(values.help ? 0 : 2);
}

const cwd = process.cwd();
const stateHome = process.env.PI_DURABLE_HOME ?? join(process.env.XDG_STATE_HOME ?? join(homedir(), ".local/state"), "pi-durable");
const sessionFile =
  values.session ?? join(stateHome, createHash("sha256").update(cwd).digest("hex").slice(0, 16), "session.sqlite");
if (values.new) for (const suffix of ["", "-wal", "-shm"]) rmSync(sessionFile + suffix, { force: true });
mkdirSync(dirname(sessionFile), { recursive: true });

const slash = values.model?.indexOf("/") ?? -1;
if (slash < 1) {
  console.error(`pi-durable: pass -m provider/model (or set PI_DURABLE_MODEL), got ${values.model ?? "nothing"}`);
  process.exit(2);
}
const model = { provider: values.model.slice(0, slash), modelId: values.model.slice(slash + 1) };

const registry = createRegistry();
registry.install(CodingTools);
registry.install(
  defineExtension({
    name: "pi-durable-cli",
    sections: [
      section("preamble", () => "You are a concise coding agent. Use the tools to inspect and change the project.", {
        tag: false,
      }),
      section("cwd", (input) => input.env?.cwd),
    ],
  }),
);

const storage = await openNodeSqliteStorage(sessionFile);
const harness = await Harness.open(
  storage,
  { models: builtinModels(), registry, env: ({ cwd: dir = cwd }) => new NodeExecutionEnv({ cwd: dir }) },
  context,
);
const root = await harness.root(context, { agent: { model, cwd } });

const textOf = (message) =>
  (message?.content ?? []).flatMap((part) => (part.type === "text" ? [part.text] : [])).join("");

try {
  if (values.resume) {
    harness.resume();
    await harness.waitForIdle(context);
    console.error(`resumed ${sessionFile}`);
  } else {
    const submission = await root.submit({ type: "input", content: positionals.join(" ") }, context);
    const settled = await submission.wait(context);
    if (settled.status === "done" && settled.type === "input") {
      const entry = await root.commit((tx) => tx.entry(AssistantEntry, settled.answer), context);
      console.log(textOf(entry?.model?.[0]));
    } else {
      console.error(`unanswered: ${settled.reason ?? settled.status}`);
      process.exitCode = 1;
    }
  }
} finally {
  await harness.close(context);
}

# Coding TUI keybindings

These bindings follow the Yazi keymap in `infra-nixCfg` and the Neovim
mappings in `Vim-Cfg`. Plain TLTR arrows keep their normal editing and
picker behavior. No base-layer substitutes are needed.

| Task | Claude Code | Codex | Pi Rust | Jcode |
| --- | --- | --- | --- | --- |
| `Alt+Up/Down` to scroll output | Fullscreen transcript, by line | Transcript pager, by line | By page | Transcript, by step |
| `U` / `R` undo and redo | In Neovim via `Ctrl+G` | In normal mode | In Neovim via `Ctrl+G` | No custom binding |
| `gg` / `G` to jump to top/bottom | No custom binding | Transcript pager | No custom binding | No custom binding |
| `Ctrl+Arrow` to focus a split | No custom binding | No custom binding | No custom binding | Workspace focus |

In Codex, `Alt+Shift+R` enters replace mode. In Pi Rust, `Alt+Shift+Up`
restores queued messages. In Jcode, `Alt+Shift+Up/Down` jumps between
prompts, and `Ctrl+Alt+Up/Down` changes speed tier. The Jcode Home Manager
settings live on `feat/jcode-home-manager` (PR #67).

The personal profile keeps Claude Code, Codex, Pi Rust, and Jcode active.
`aiCoding.installArchivedTools = true` opts back into the auxiliary CLI
collection, including `zai`. Provider auth and session state are not removed.

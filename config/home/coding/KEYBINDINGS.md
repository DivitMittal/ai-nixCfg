# TLTR Colemak Mod-DH navigation

On TLTR’s thumb-left layer, use the arrows at the `N`, `E`, `U`, and `I`
positions (left, down, up, and right). These are the most portable shortcuts.
On the base layer, `Ctrl+Alt+N/E/U/I` reuse those positions where the app
exposes the corresponding action. No bare letters are remapped in the composer.

| App | Base-layer shortcuts | Arrow fallback |
| --- | --- | --- |
| Claude Code | `Ctrl+Alt+U/E` for prompt history and supported lists | Arrows for editing and list movement |
| Codex | `Ctrl+Alt+N/E/U/I` in the editor and supported lists; `Ctrl+Alt+U/E` in the transcript pager | Arrows; `Ctrl+Shift+Up/Down` also works in the pager |
| Pi Rust | `Ctrl+Alt+N/E/U/I` in the editor; vertical movement also browses history in one-line input | Arrows, including in pickers |
| Jcode | `Ctrl+Alt+N/E/U/I` to move workspace focus | `Ctrl+Alt+Arrow` for workspace focus; arrows for input |

`PageUp/PageDown` page through the Jcode transcript and the Codex pager.
In Jcode, `Ctrl+Shift+Up/Down` scrolls one step and `Alt+Shift+Up/Down`
jumps between prompts. The Jcode Home Manager configuration is on
`feat/jcode-home-manager` (PR #67), not on `master`.

If the terminal or multiplexer intercepts a modified base-layer key, use the
TLTR arrows. On macOS, `Alt` refers to Option sent as terminal Meta.

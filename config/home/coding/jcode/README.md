# Jcode

Home Manager installs the pinned Jcode package and applies `programs.jcode.settings`
to `~/.jcode/config.toml` on each activation. Declared values win at activation.
Other settings remain writable, so Jcode can still save model and display
preferences. Credentials and session data are not managed by Nix. Don't put
secrets in `settings`: their values would be copied into the Nix store.

The personal profile uses Yazi's preview-scroll gesture and Vim-Cfg's split
focus gesture. It leaves plain arrows for text editing and list movement.

| Action | Binding |
| --- | --- |
| Scroll transcript by a step | `Alt+Up/Down` |
| Scroll transcript by a page | `PageUp/PageDown` |
| Jump to the previous/next prompt | `Alt+Shift+Up/Down` |
| Move workspace focus (only after `/workspace on`) | `Ctrl+Arrow` |
| Change speed tier | `Ctrl+Alt+Up/Down` |

`Ctrl+Arrow` does nothing for workspaces until `/workspace on`. Until then,
`Ctrl+Left/Right` stay word motions and `Ctrl+Up/Down` stay prompt recall.
For prompt recall while workspace mode is on, use plain `Up/Down` or
`Cmd+Up/Down` on macOS.

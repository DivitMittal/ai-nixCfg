# Jcode

Home Manager installs the pinned Jcode package and applies `programs.jcode.settings`
to `~/.jcode/config.toml` on each activation. Declared values win at activation.
Other settings remain writable, so Jcode can still save model and display
preferences. Credentials and session data are not managed by Nix. Don't put
secrets in `settings`: their values would be copied into the Nix store.

The personal profile uses the TLTR thumb-left navigation layer, so it does not
depend on QWERTY `hjkl` positions or take over unmodified keys in the prompt:

| Action | Binding on the TL layer |
| --- | --- |
| Scroll transcript by a step | `Ctrl+Shift+Up/Down` |
| Scroll transcript by a page | `PageUp/PageDown` |
| Jump to the previous/next prompt | `Alt+Shift+Up/Down` |
| Move workspace focus | `Ctrl+Alt+Arrow` |

Plain arrows and `Ctrl+Up/Down` still handle normal input navigation and prompt
history. Open a new Jcode client after activating to pick up the bindings.

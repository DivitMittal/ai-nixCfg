_: {
  programs.codex = {
    profiles = {
      default = {
        model = "gpt-5.2-codex";
        approval_policy = "on-request";
        sandbox_mode = "workspace-write";
      };

      conservative = {
        model = "gpt-5.2-codex";
        approval_policy = "untrusted";
        sandbox_mode = "read-only";
      };

      power = {
        model = "gpt-5.2-codex";
        model_reasoning_effort = "xhigh";
        approval_policy = "on-failure";
        sandbox_mode = "workspace-write";

        sandbox_workspace_write = {
          network_access = true;
        };
      };
    };

    settings = {
      # ===== Core Model Settings =====
      model = "gpt-5.2-codex";

      # GPT-5 specific settings
      model_reasoning_effort = "medium";
      model_reasoning_summary = "detailed";
      model_verbosity = "medium";

      # ===== TUI =====
      tui = {
        notifications = true;
        animations = true;
        pet = "custom:pico";
        keymap = {
          # TLTR's arrow positions on the Colemak base layer: N/E/U/I.
          # Keep arrows and the stock bindings as fallbacks.
          editor = {
            move_left = ["left" "ctrl-b" "ctrl-alt-n"];
            move_down = ["down" "ctrl-n" "ctrl-alt-e"];
            move_up = ["up" "ctrl-p" "ctrl-alt-u"];
            move_right = ["right" "ctrl-f" "ctrl-alt-i"];
          };
          list = {
            move_left = ["left" "ctrl-h" "ctrl-alt-n"];
            move_down = ["down" "ctrl-n" "ctrl-j" "j" "ctrl-alt-e"];
            move_up = ["up" "ctrl-p" "ctrl-k" "k" "ctrl-alt-u"];
            move_right = ["right" "ctrl-l" "ctrl-alt-i"];
          };
          pager = {
            scroll_up = ["up" "k" "ctrl-alt-u" "ctrl-shift-up"];
            scroll_down = ["down" "j" "ctrl-alt-e" "ctrl-shift-down"];
          };
        };
      };
      check_for_update_on_startup = false;
      cli_auth_credentials_store = "file";
      feedback.enabled = false;
      project_doc_fallback_filenames = ["CLAUDE.md"];
      startup_timeout_sec = "60";

      # ===== Features =====
      features = {
        shell_snapshot = true;
        web_search_request = true;
        tui2 = true;
      };

      # ===== Security & Approvals =====
      approval_policy = "on-request";
      sandbox_mode = "workspace-write";

      sandbox_workspace_write = {
        network_access = true;
        exclude_tmpdir_env_var = false;
        exclude_slash_tmp = false;
      };
    };
  };
}

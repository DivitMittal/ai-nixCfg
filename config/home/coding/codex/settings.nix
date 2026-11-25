_: {
  programs.codex = {
    profiles = {
      default = {
        approval_policy = "on-request";
        sandbox_mode = "workspace-write";
      };

      conservative = {
        approval_policy = "untrusted";
        sandbox_mode = "read-only";
      };

      power = {
        model_reasoning_effort = "xhigh";
        approval_policy = "on-failure";
        sandbox_mode = "workspace-write";

        sandbox_workspace_write = {
          network_access = true;
        };
      };
    };

    settings = {
      # ===== Reasoning and Output =====
      model_reasoning_effort = "medium";
      model_reasoning_summary = "detailed";
      model_verbosity = "medium";

      # ===== TUI =====
      tui = {
        notifications = true;
        animations = true;
        pet = "custom:pico";
        vim_mode_default = true;
        keymap = {
          # Match Vim-Cfg: U/R undo and redo. Move replace mode out of R's way.
          vim_normal = {
            undo = ["shift-u"];
            redo = ["shift-r" "ctrl-r"];
            enter_replace_mode = ["shift-alt-r"];
            move_left = ["left"];
            move_down = ["down"];
            move_up = ["up"];
            move_right = ["right"];
          };
          vim_operator = {
            motion_left = ["left"];
            motion_down = ["down"];
            motion_up = ["up"];
            motion_right = ["right"];
          };
          pager = {
            scroll_up = ["up" "alt-up"];
            scroll_down = ["down" "alt-down"];
            # Pager chords cannot start with an unmodified character.
            jump_top = ["home"];
            jump_bottom = ["end" "shift-g"];
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

{
  pkgs,
  config,
  ...
}: {
  programs.aichat = {
    enable = true;
    package = pkgs.aichat;

    settings = {
      highlight = true;
      light_theme = false;
      left_prompt = "{color.green}{?session {?agent {agent}>}{session}{?role /}}{!session {?agent {agent}>}}{role}{?rag @{rag}}{color.cyan}{?session )}{!session >}{color.reset} ";
      right_prompt = "{color.purple}{?session {?consume_tokens {consume_tokens}({consume_percent}%)}{!consume_tokens {consume_tokens}}}{color.reset}";
      editor = "${config.home.sessionVariables.EDITOR}";
      keybindings = "vim";
      wrap = "auto";
      wrap_code = false;
      model = "openrouter:qwen/qwen3-next-80b-a3b-instruct:free";
      models = [
        # Coding
        {
          name = "openrouter:qwen/qwen3-coder:free";
          max_input_tokens = 1048576;
        }
        {
          name = "openrouter:cohere/north-mini-code:free";
          max_input_tokens = 256000;
        }

        # General / Chat (large)
        {
          name = "openrouter:nousresearch/hermes-3-llama-3.1-405b:free";
          max_input_tokens = 131072;
        }
        {
          name = "openrouter:nvidia/nemotron-3-ultra-550b-a55b:free";
          max_input_tokens = 1000000;
        }
        {
          name = "openrouter:openai/gpt-oss-120b:free";
          max_input_tokens = 131072;
        }
        {
          name = "openrouter:nvidia/nemotron-3-super-120b-a12b:free";
          max_input_tokens = 1000000;
        }

        # General / Chat (mid)
        {
          name = "openrouter:meta-llama/llama-3.3-70b-instruct:free";
          max_input_tokens = 131072;
        }
        {
          name = "openrouter:qwen/qwen3-next-80b-a3b-instruct:free";
          max_input_tokens = 262144;
        }
        {
          name = "openrouter:google/gemma-4-31b-it:free";
          max_input_tokens = 262144;
        }

        # Reasoning
        {
          name = "openrouter:nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free";
          max_input_tokens = 256000;
        }
        {
          name = "openrouter:liquid/lfm-2.5-1.2b-thinking:free";
          max_input_tokens = 32768;
        }

        # Small / Fast
        {
          name = "openrouter:google/gemma-4-26b-a4b-it:free";
          max_input_tokens = 262144;
        }
        {
          name = "openrouter:meta-llama/llama-3.2-3b-instruct:free";
          max_input_tokens = 131072;
        }
        {
          name = "openrouter:nvidia/nemotron-3-nano-30b-a3b:free";
          max_input_tokens = 256000;
        }

        # Auto / Fallback
        {
          name = "openrouter:openrouter/free";
          max_input_tokens = 200000;
        }
      ];
      clients = [
        {
          type = "openai-compatible";
          name = "openrouter";
          api_base = "https://openrouter.ai/api/v1";
          # api_key = ""; # Using environment variables instead
        }
        {
          type = "openai-compatible";
          name = "groq";
          api_base = "https://api.groq.com/openai/v1";
          # api_key = ""; # Using environment variables instead
        }
        {
          type = "gemini";
          api_base = "https://generativelanguage.googleapis.com/v1beta";
          # api_key = ""; # Using environment variables instead
        }
      ];
    };
  };
}

{
  pkgs,
  config,
  ...
}: {
  programs.mods = {
    enable = false;
    package = pkgs.mods;

    enableBashIntegration = false;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;

    settings = {
      default-model = "gpt-oss";

      roles = {
        shell = [
          "you are a shell expert"
          "you don't explain anything"
          "you simply output one liners to solve the problems you're asked"
          "you don't provide any explanation whatsoever, only the command"
        ];
      };

      apis = {
        groq = {
          base-url = "https://api.groq.com/openai/v1";
          api-key-env = "GROQ_API_KEY";
          models = {
            "openai/gpt-oss-120b" = {
              aliases = ["gpt-oss"];
            };
            "moonshotai/kimi-k2-instruct-0905" = {
              aliases = ["kimi"];
            };
            "qwen/qwen3-32b" = {
              aliases = ["qwen3"];
            };
          };
        };
        openrouter = {
          base-url = "https://openrouter.ai/api/v1";
          api-key-env = "OPENROUTER_API_KEY";
          models = {
            "z-ai/glm-4.5-air:free" = {
              aliases = ["glm"];
            };
            "stepfun/step-3.5-flash:free" = {
              aliases = ["stepfun"];
            };
            "deepseek/deepseek-chat-v3.1:free" = {
              aliases = ["deepseek"];
            };
          };
        };
        google = {
          api-key-env = "GEMINI_API_KEY";
          models = {
            "gemini-3.1-flash-lite-preview" = {
              aliases = ["gemini-flash-lite"];
            };
            "gemini-3-flash-preview" = {
              aliases = ["gemini-flash"];
            };
            "gemini-3.1-pro-preview" = {
              aliases = ["gemini-pro"];
            };
          };
        };
      };
    };
  };
}

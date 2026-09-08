{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  fabricConfig = (pkgs.formats.yaml {}).generate "fabric-config.yaml" {
    vendor = "OpenRouter";
    model = "qwen/qwen3-next-80b-a3b-instruct:free";
    stream = true;
    suppressThink = true;
  };
in {
  programs.fabric-ai = {
    enable = true;
    package = pkgs.fabric-ai;

    enableBashIntegration = false;
    enableZshIntegration = false;
    enablePatternsAliases = false;
    enableYtAlias = false;
  };

  home.packages = [
    pkgs.yt-dlp
  ];

  xdg.configFile."fabric/config.yaml".source = fabricConfig;

  programs.fish.functions = mkIf config.programs.fish.enable {
    fpatterns = {
      description = "List Fabric patterns, using fzf when available";
      body = ''
        if type -q fzf
          fabric --listpatterns | fzf --height=40% --reverse --prompt="fabric pattern> "
        else
          fabric --listpatterns
        end
      '';
    };

    fpat = {
      description = "Run a Fabric pattern over stdin or a short prompt";
      body = ''
        set -l pattern

        if test (count $argv) -eq 0
          set pattern (fpatterns)
          test -n "$pattern"; or return 1
        else
          set pattern $argv[1]
          set -e argv[1]
        end

        if test (count $argv) -gt 0
          string join " " -- $argv | fabric --pattern "$pattern"
        else
          fabric --pattern "$pattern"
        end
      '';
    };

    fcmd = {
      description = "Ask Fabric to create a shell command";
      body = ''
        if test (count $argv) -eq 0
          echo "Usage: fcmd <what you want the shell command to do>" >&2
          return 1
        end

        string join " " -- $argv | fabric --pattern create_command
      '';
    };

    fyt = {
      description = "Send a YouTube transcript to Fabric";
      body = ''
        set -l transcript_flag --transcript
        set -l fabric_args

        while test (count $argv) -gt 0
          switch $argv[1]
            case -t --timestamps
              set transcript_flag --transcript-with-timestamps
              set -e argv[1]
            case -p --pattern
              if test (count $argv) -lt 2
                echo "Usage: fyt [-t|--timestamps] [-p pattern] <youtube-url>" >&2
                return 1
              end
              set -a fabric_args --pattern $argv[2]
              set -e argv[1..2]
            case '*'
              break
          end
        end

        if test (count $argv) -ne 1
          echo "Usage: fyt [-t|--timestamps] [-p pattern] <youtube-url>" >&2
          return 1
        end

        fabric --youtube "$argv[1]" $transcript_flag $fabric_args
      '';
    };
  };
}

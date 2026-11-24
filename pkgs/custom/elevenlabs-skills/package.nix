{
  lib,
  runCommand,
  writeText,
  sources,
}: let
  source = sources.elevenlabs-skills;

  # Official hosted MCP (OAuth). Not a Claude plugin marketplace, so this
  # file is reference only: the server stays out of the shared programs.mcp
  # set and is added per project, same as Higgsfield.
  mcpJson = writeText "elevenlabs-mcp.json" (builtins.toJSON {
    mcpServers.elevenlabs = {
      type = "http";
      url = "https://api.elevenlabs.io/v1/mcp";
    };
  });

  # Product skills only. `.agents/` is the skills repo's own maintainer
  # tooling, and `evals/` needs Cursor to run.
  skillNames = [
    "agents"
    "dubbing"
    "music"
    "onboarding"
    "realtime"
    "setup-api-key"
    "sound-effects"
    "speech-engine"
    "speech-to-text"
    "text-to-speech"
    "voice-changer"
    "voice-isolator"
  ];
in
  runCommand "elevenlabs-skills-${source.date}" {
    passthru = {inherit (source) version;};
    meta = {
      description = "ElevenLabs agent skills (text-to-speech, agents, music, dubbing, ...)";
      homepage = "https://github.com/elevenlabs/skills";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  } ''
    mkdir -p $out
    ${lib.concatMapStrings (name: ''
        cp -r ${source.src}/${name} $out/${name}
      '')
      skillNames}
    chmod -R u+w $out
    install -m644 ${mcpJson} $out/mcp.json
  ''

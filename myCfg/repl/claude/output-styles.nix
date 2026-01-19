_: {
  programs.claude-code = {
    settings.outputStyle = "Default";

    output-styles = {
      bullet-points = builtins.readFile ./output-styles/bullet-points.md;
      genui = builtins.readFile ./output-styles/genui.md;
      html-structured = builtins.readFile ./output-styles/html-structured.md;
      markdown-focused = builtins.readFile ./output-styles/markdown-focused.md;
      table-based = builtins.readFile ./output-styles/table-based.md;
      ultra-concise = builtins.readFile ./output-styles/ultra-concise.md;
      yaml-structured = builtins.readFile ./output-styles/yaml-structured.md;
    };
  };
}

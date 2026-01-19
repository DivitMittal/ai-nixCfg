_: {
  programs.claude-code = {
    settings.outputStyle = "Default";

    output-styles = {
      bullet-points = builtins.readFile ./bullet-points.md;
      genui = builtins.readFile ./genui.md;
      html-structured = builtins.readFile ./html-structured.md;
      markdown-focused = builtins.readFile ./markdown-focused.md;
      table-based = builtins.readFile ./table-based.md;
      ultra-concise = builtins.readFile ./ultra-concise.md;
      yaml-structured = builtins.readFile ./yaml-structured.md;
    };
  };
}

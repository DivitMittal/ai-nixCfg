---
allowed-tools: Read, Edit, Write, Grep, Glob
argument-hint: <file-or-symbol>
description: Refactor code to appear human-written by eliminating AI/LLM telltale patterns
---

# Human Code Refactor

Refactor code to eliminate patterns that signal AI/LLM authorship.

## Forbidden Patterns

### Comments
**REMOVE** (obvious/decorative):
- Decorative blocks (`# ===`, `# ---`, `# ***`)
- ASCII art headers or section banners
- Comments restating what code obviously does (`# increment i` above `i += 1`)
- Generic labels (`# Main entry point`, `# Helper function`, `# Utility method`)
- Comments repeating variable/function names in prose form
- "TODO: implement" placeholders unless specifically requested

**KEEP** (adds value):
- Technical explanations of WHY not WHAT (`# offset by 1 to skip header row`)
- Non-obvious edge cases (`# nil check: upstream API returns null on 404`)
- Performance/algorithm notes (`# O(n log n) - sorted for binary search`)
- Caveats or gotchas (`# WARN: not thread-safe, caller must hold lock`)
- Brief clarifications for dense/tricky logic
- References to specs, tickets, or external docs

Comments should be terse and technical. When in doubt, keep the comment if it explains something non-obvious from the code itself.

### Naming
- No overly verbose names (`user_authentication_service_handler_manager`)
- No redundant type suffixes (`user_list_array`, `count_integer`, `is_valid_boolean`)
- No `_impl`, `_helper`, `_util` suffixes unless codebase convention
- Prefer short, contextually clear names (`users` not `list_of_user_objects`)

### Structure
- No excessive abstraction for simple tasks
- No wrapper functions that just call one other function
- No factory/builder/strategy patterns for trivial operations
- No unnecessary class hierarchies - use functions when appropriate
- Inline short operations instead of extracting micro-functions

### Formatting
- No em dashes anywhere in strings or comments; use regular dashes (-) or rewrite
- No emojis in code, comments, logs, or output
- No fancy Unicode characters (arrows, bullets, checkmarks) in output
- No overly formatted console output with boxes or decorative borders
- No excessive blank lines between every block

### Documentation
- No docstrings that repeat the function name and parameters verbatim
- No docstrings for self-explanatory functions (`def get_name(): return self.name`)
- No "Args/Returns/Raises" sections for simple one-liners
- Docstrings only for complex public APIs or non-obvious behavior

### Code Style
- Allow minor inconsistencies humans naturally have
- Don't over-optimize or prematurely abstract
- Keep error messages terse and practical, not overly helpful prose
- Avoid triple-quoted strings for simple single-line messages
- Use contractions naturally in user-facing strings when appropriate

### Logging/Output
- No progress messages for sub-second operations
- No "Successfully completed X" messages unless necessary
- No verbose status updates for every step
- Error messages: direct and practical, not apologetic or overly explanatory

## Refactoring Checklist

1. Strip decorative/obvious comments (keep technical ones that add value)
2. Shorten verbose variable/function names
3. Inline trivial helper functions
4. Remove unnecessary abstraction layers
5. Replace em dashes with hyphens or reword
6. Remove emojis and Unicode decoration
7. Delete self-evident docstrings
8. Consolidate excessive whitespace
9. Simplify over-engineered patterns
10. Make error messages terse

## Output

Return only the refactored code. No explanations, summaries, or before/after comparisons unless explicitly requested.

---
name: bash-script
description: Write robust Bash scripts matching GNU/Linux CLI conventions.
---

# Bash Script Skill

## Purpose
Write robust Bash scripts matching GNU/Linux CLI conventions.

## Workflow
1. First, ask clarifying questions to fully specify the desired features
2. Next, confirm the full CLI signature `-h|--h` with the user and iterate
3. One confirmed, proceed with script implementation
4. Lastly, verify all completion criteria are satisfied

## Best Practices
- Provide an intuitive CLI consistent with other GNU/Linux tools
- Promote brevity and clarity with fewer, more conscise lines
- Use `#!/usr bin env bash` and `set -euo pipefail`
- Document usage in a `usage()` function block
- Always check for required external commands (`command -v`)
- Provide explicit error messages with status code checking
- Use `getopt` for option parsing (provide both short and long flags)
- Add `-h|--help` and `-v|--version` options
- Prefer `$(cmd)` over backticks for command substitution
- Prefer `foo_bar()` syntax for functions (snake_case)
- Always quote `"${VARIABLE_EXPANSION}"`

## Completion Criteria
- `-h|--help` matches the user specification for the tool
- Marked executable with `chmod +x`
- Passes `shellcheck` (or `uvx --from shellcheck-py shellcheck`) clean

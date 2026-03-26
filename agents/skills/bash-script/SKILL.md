---
name: bash-script
description: |
  Write robust and maintainable Bash scripts. 
  CLI should match the look and feel of GNU/Linux tools.
---

# Bash Script Skill

## Purpose
Create, review, or refactor Bash scripts to:
- Follow the [Shell Style Guide](https://style.ysap.sh/md)
- Use `getopt` for command-line parsing (supporting both short and long options)
- Define a clear, consistent CLI interface (help, version, error handling)
- Pass `shellcheck` with no warnings or errors
- Match the CLI conventions of GNU/Linux tools

## Workflow

1. **Draft the Script**
   - Start with a shebang (`#!/usr/bin/env bash`)
   - Set `set -euo pipefail` for safety
   - Use `getopt` for option parsing (short and long options)
   - Implement `-h|--help` and `-v|--version` if appropriate
   - Document usage in a function or comment block

2. **Style and Lint**
   - Follow the [Shell Style Guide](https://style.ysap.sh/md) for formatting, naming, quoting, and error handling
   - Run `shellcheck` and resolve all warnings/errors

3. **Testing**
   - Test all CLI options and error cases
   - Ensure the script behaves like standard GNU/Linux tools

4. **Review**
   - Check for maintainability, readability, and portability
   - Ensure all external commands are checked for existence if required

## Completion Criteria
- Script passes `shellcheck` with no warnings/errors
- CLI uses `getopt` and matches GNU/Linux conventions
- Usage/help output is clear and accurate
- Follows the Shell Style Guide

## Example Prompts
- "Write a bash script that backs up a directory, using getopt for options."
- "Refactor this script to use getopt and pass shellcheck."
- "Add a --help option and ensure the script follows the Shell Style Guide."

## Related Customizations
- Shell Style Guide reference in documentation
- Pre-commit hook to run shellcheck on all scripts
- Template for new bash scripts with getopt and help/version

---
name: new-project
argument-hint: "Project name (optional)"
description: "Initialize a new Python project in an empty repository."
agent: agent
---

# New Python Project Initialization

This prompt scaffolds a new Python project in an empty repository, following best practices for structure, documentation, and testing.

## Steps Performed
1. Create a project directory (if not present)
2. Add a `README.md` with project description
3. Initialize a Python virtual environment
4. Create a `src/` directory for source code
5. Create a `tests/` directory for tests
6. Add a `.gitignore` for Python
7. Optionally initialize a Git repository
8. Add a `requirements.txt` (empty or with user-specified packages)
9. Add a sample main module (e.g., `src/main.py`)

## Inputs
- Project name (optional)
- Description (optional)
- Initial dependencies (optional)
- Initialize git? (yes/no)

## Output
A ready-to-use Python project structure with all files created and instructions for next steps.

## Example Usage
- /new-project
- /new-project MyApp
- /new-project MyApp --desc "A CLI tool" --deps requests,pytest --git

---

Follow the Unix philosophy and YAGNI: keep the structure minimal, composable, and well-documented. Always include a README and test directory. Prompt the user for any missing information.

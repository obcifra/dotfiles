---
applyTo: "**"
---

# General Principles

## Unix Philosophy
- Write simple, modular, and composable code.
- Each script, function, or module should do one thing well.
- Prefer small, focused tools over monolithic solutions.

## YAGNI
- Avoid excessive abstraction.
- Avoid premature optimization.
- Do the simplest thing that could possibly work.

## Design Guidelines
- **IMPORTANT**: Describe the solution and get feedback before writing code.
- Use design patterns and best practices where appropriate.

## Documentation Guidelines
- Maintain a clear README with setup, usage, and contribution instructions.
- Document assumptions, limitations, and design decisions.
- Document all public interfaces, functions, and modules.
- Use clear, concise comments to explain non-obvious logic.
- Update documentation with every code or interface change.

## Implementation Guidelines
- Use meaningful names for variables, functions, and files.
- Keep functions and scripts short and focused.
- Prefer clarity over cleverness in code.
- Write portable, environment-agnostic code when possible.
- Handle errors gracefully and provide informative error messages.

## Testing Guidelines
- Practice Test-Driven Development (TDD).
  Write tests before implementing new features or fixing bugs.
- Place tests alongside the code or in a dedicated `test` directory.
- Use automated test runners and include instructions for running tests.
- Ensure all code changes are covered by automated tests.
- Refactor only with green tests.

# AGENTS.md — playbook/

Ansible playbooks that provision a single-user dev environment on localhost
(no root, installs under `~/.local`). Follow these conventions for new and
edited playbooks.

## Layout and running

- One playbook per tool: `playbook-get<tool>.yml` (single tool/installer) or
  `playbook-provision-<group>.yml` (groups). Shared logic goes in `tasks/`.
- Run via `./play [-c] <file>`; never call `ansible-playbook` directly.
  `-c` is a dry run (`--check`) and must succeed on every playbook.
- Lint with `./play -l <file>` or `./play -l all` before finishing. It must pass
  (profile `production`, see `.ansible-lint`).
- `archive/` holds retired playbooks; do not edit or copy from them.

## Preferred pattern: pinned archive/binary

Use `tasks/fetch_package.yml` + `tasks/install_package.yml` whenever the tool
ships a release tarball or single binary. See `playbook-getneovim.yml`.

- Required vars: `package_id`, `package_version`, `package_type`
  (`archive`|`binary`), `package_name`, `package_link`, `package_hash`
  (sha256, hex, no prefix), `package_bins` (`[{src, lnk}]`).
- Optional: `package_strip` for archives with a top-level directory.
- Installs go to `~/.local/opt/<id>-<version>/`, links to `~/.local/bin/`.
- Bump a tool by changing `package_version` **and** `package_hash` together.
- Installer scripts/binaries (`rustup-init`, nvm `install.sh`): use
  `package_type: "binary"` and omit `lnk`, then run it from `{{ package_dir }}`
  gated on a version probe (`when: installed_version != package_version`).
  See `playbook-getrustup.yml` and `playbook-getnodejs.yml`.
- Extend the shared tasks rather than copying their logic into a playbook.

## Required conventions

- Header: `---`, play `name:` in sentence case, `hosts: localhost`,
  `become: false`. Use `become` only per-task and only when unavoidable.
- Use fully qualified module names (`ansible.builtin.*`).
- Every task has a `name:` starting with a capital letter.
- YAML: 2-space indent, double-quoted strings, file modes quoted (`"0755"`).
- All variables live in play-level `vars:`; no versions, URLs or hashes inline
  in tasks. Prefix role-specific vars with the tool (`nvm_version`).
- Never hard-code `/home/<user>`; use `ansible_facts['env']['HOME']`.
- Temp files: use `ansible.builtin.tempfile` (honours `TMPDIR`) with
  `check_mode: false`, and remove it in an `always:` block or `post_tasks`.
- Playbooks are comment-light; add a short header comment only for non-obvious
  required vars or behaviour.

## Security

- Pin every version. No `latest`, `stable`, or unpinned URLs.
- Every download must use `get_url` with `checksum: "sha256:<hash>"`. Do not
  pipe `curl | sh`. Installer scripts must be downloaded, checksummed, then run.
- Downloads are untrusted: do not execute from the download directory
  except for a verified installer.

## Idempotency and check mode

- A second run must report `changed=0`. Verify by running twice.
- Prefer native modules (`file`, `get_url`, `unarchive`, `copy`, `package`)
  over `command`/`shell`. Use `shell` only if pipes, `source`, or env are needed.
- Every `command`/`shell` task must have `changed_when` and one of `creates:`,
  `removes:`, or a preceding version-check task whose result gates it.
  `changed_when: false` is only for read-only queries, never for tasks that
  modify state (e.g. `rustup update` should report real changes).
- Do not use `ignore_errors: true`. Use `failed_when: false` on read-only
  probes and check `rc` explicitly. Prefer `ansible.builtin.stat` or
  `command -v` (via `ansible.builtin.command`) over `which`.
- Version gates must compare against the installed version and cover
  upgrades, not just first install (`creates:` alone will skip upgrades).
- Read-only probe tasks need `check_mode: false` so dependent tasks work
  under `--check`.
- Loops should use `loop_control.label` to keep output readable.

## Adding a new playbook

1. Copy `playbook-getneovim.yml` (archive) or the closest existing playbook.
2. Fill in pinned version, URL and sha256 (compute with `sha256sum`).
3. `./play -l <file>`, `./play -c <file>`, `./play <file>`, then run again and
   confirm `changed=0`.
4. Add any non-automatable steps to the Drafts list in `README.md`.

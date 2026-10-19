#!/usr/bin/env bash
# Initialize a two-pane tmux workspace.
set -euo pipefail

readonly PROGRAM_NAME="${0##*/}"
readonly VERSION="1.0.0"

usage() {
    cat <<EOF
Usage: ${PROGRAM_NAME} [OPTIONS] [DIRECTORY]

Initialize a tmux workspace for DIRECTORY (default: current directory).

Arguments:
  DIRECTORY              Existing target directory (default: current directory)

Options:
  -h, --help             Display this help and exit
  -v, --version          Display version information and exit
EOF
}

die() {
    printf '%s: %s\n' "${PROGRAM_NAME}" "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

workspace_exists() {
    tmux list-windows -t "${1}:workspace" >/dev/null 2>&1
}

configure_workspace() {
    local window_target=$1
    local target_directory=$2
    shift 2
    local -a editor_command=("$@")
    local left_pane right_pane

    left_pane=$(tmux display-message -p -t "${window_target}" '#{pane_id}')
    right_pane=$(tmux split-window -d -h -p 60 -P -F '#{pane_id}' \
        -t "${left_pane}" -c "${target_directory}" \
        "${editor_command[@]}" "${target_directory}")

    tmux select-pane -t "${left_pane}" -T agent
    tmux select-pane -t "${right_pane}" -T editor
    tmux set-option -w -t "${window_target}" pane-border-status top
    tmux set-option -w -t "${window_target}" pane-border-format ' #{pane_title} '
}

main() {
    local parsed_options target_input target_directory session_name window_target
    local editor_value
    local -a editor_command
    local inside_tmux=false

    require_command basename
    require_command getopt
    require_command tmux

    if ! parsed_options=$(getopt --options hv --longoptions help,version \
        --name "${PROGRAM_NAME}" -- "$@"); then
        usage >&2
        exit 2
    fi
    # getopt emits shell-quoted arguments; this is its documented interface.
    # shellcheck disable=SC2086
    eval set -- "${parsed_options}"

    while true; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                printf '%s %s\n' "${PROGRAM_NAME}" "${VERSION}"
                exit 0
                ;;
            --)
                shift
                break
                ;;
        esac
    done

    (($# <= 1)) || {
        usage >&2
        exit 2
    }
    target_input=${1:-.}
    [[ -d "${target_input}" ]] || die "not a directory: ${target_input}"
    target_directory=$(cd "${target_input}" && pwd -P)

    editor_value=${EDITOR:-vim}
    read -r -a editor_command <<< "${editor_value}"
    ((${#editor_command[@]} > 0)) || die "EDITOR must name an editor command"
    require_command "${editor_command[0]}"

    if [[ -n ${TMUX:-} ]]; then
        inside_tmux=true
        session_name=$(tmux display-message -p '#{session_name}')
    else
        session_name=$(basename "${target_directory}")
    fi

    if ! tmux has-session -t "${session_name}" 2>/dev/null; then
        tmux new-session -d -s "${session_name}" -n workspace -c "${target_directory}"
        configure_workspace "${session_name}:workspace" "${target_directory}" \
            "${editor_command[@]}"
    elif ! workspace_exists "${session_name}"; then
        window_target=$(tmux new-window -d -P -F '#{window_id}' -t "${session_name}" \
            -n workspace -c "${target_directory}")
        configure_workspace "${window_target}" "${target_directory}" \
            "${editor_command[@]}"
    fi

    if [[ "${inside_tmux}" == true ]]; then
        tmux select-window -t "${session_name}:workspace"
    else
        tmux attach-session -t "${session_name}:workspace"
    fi
}

main "$@"

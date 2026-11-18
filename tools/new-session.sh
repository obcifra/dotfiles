#!/usr/bin/env bash
# Initialize a persistent tmux workspace.
set -euo pipefail

readonly PROGRAM_NAME="${0##*/}"
readonly VERSION="2.1.0"

usage() {
    cat <<EOF
Usage: ${PROGRAM_NAME} [OPTIONS] [DIRECTORY]

Initialize a tmux workspace for DIRECTORY (default: current directory).

Arguments:
  DIRECTORY              Existing target directory (default: current directory)

Options:
      --ade              Use editor, agent, and shell panes (default)
      --ide              Use editor and shell panes
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

window_name_for_directory() {
    local target_directory=$1
    local parent_directory

    # Display the final component at the filesystem root, otherwise retain the
    # directory and its immediate parent.
    [[ "${target_directory}" == / ]] && {
        printf '/\n'
        return
    }

    parent_directory=${target_directory%/*}
    if [[ -z "${parent_directory}" || "${parent_directory}" == / ]]; then
        printf '%s\n' "${target_directory##*/}"
    else
        printf '%s/%s\n' "${parent_directory##*/}" "${target_directory##*/}"
    fi
}

configure_window() {
    local window_target=$1
    local target_directory=$2
    local workspace_mode=$3
    shift 3
    local -a editor_command=("$@")
    local editor_pane shell_pane agent_pane

    # Start with a shell so remain-on-exit can be enabled before the editor
    # command is run; an editor that exits immediately must still leave a pane.
    editor_pane=$(tmux display-message -p -t "${window_target}" '#{pane_id}')
    tmux set-option -w -t "${window_target}" remain-on-exit on
    tmux set-option -w -t "${window_target}" pane-border-status top
    tmux set-option -w -t "${window_target}" pane-border-format ' #{pane_title} '

    # Split vertically first so the shell spans the bottom 20% of the window.
    shell_pane=$(tmux split-window -d -v -p 20 -P -F '#{pane_id}' \
        -t "${editor_pane}" -c "${target_directory}")

    tmux select-pane -t "${editor_pane}" -T editor
    tmux select-pane -t "${shell_pane}" -T shell
    if [[ "${workspace_mode}" == ade ]]; then
        # The remaining top area is split 60/40 between editor and agent.
        agent_pane=$(tmux split-window -d -h -p 40 -P -F '#{pane_id}' \
            -t "${editor_pane}" -c "${target_directory}")
        tmux select-pane -t "${agent_pane}" -T agent
    fi
    tmux respawn-pane -k -t "${editor_pane}" -c "${target_directory}" \
        "${editor_command[@]}" "${target_directory}"

    # The targets are relative to the active window, so these prefix bindings
    # work for every workspace window created by this script.
    if [[ "${workspace_mode}" == ade ]]; then
        tmux bind-key -T prefix a select-pane -t '{top-right}'
    fi
    tmux bind-key -T prefix e select-pane -t '{top-left}'
    tmux bind-key -T prefix s select-pane -t '{bottom-left}'
}

main() {
    local parsed_options target_input target_directory window_name session_name window_target
    local editor_value selected_mode="" workspace_mode=ade
    local -a editor_command
    local inside_tmux=false

    require_command basename
    require_command getopt
    require_command tmux

    if ! parsed_options=$(getopt --options hv --longoptions ade,ide,help,version \
        --name "${PROGRAM_NAME}" -- "$@"); then
        usage >&2
        exit 2
    fi
    # getopt emits shell-quoted arguments; this is its documented interface.
    # shellcheck disable=SC2086
    eval set -- "${parsed_options}"

    while true; do
        case "$1" in
            --ade|--ide)
                workspace_mode=${1#--}
                if [[ -n "${selected_mode}" && "${selected_mode}" != "${workspace_mode}" ]]; then
                    die "--ade and --ide are mutually exclusive"
                fi
                selected_mode=${workspace_mode}
                shift
                ;;
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
    window_name=$(window_name_for_directory "${target_directory}")

    editor_value=${EDITOR:-vim}
    read -r -a editor_command <<< "${editor_value}"
    ((${#editor_command[@]} > 0)) || die "EDITOR must name an editor command"
    require_command "${editor_command[0]}"

    if [[ -n ${TMUX:-} ]]; then
        inside_tmux=true
    fi

    if tmux has-session 2>/dev/null; then
        # A running tmux server always gets a fresh workspace window.  Outside
        # tmux, attach to an existing session after making that window active.
        if [[ "${inside_tmux}" == true ]]; then
            session_name=$(tmux display-message -p '#{session_name}')
        else
            read -r session_name < <(tmux list-sessions -F '#{session_name}')
        fi
        window_target=$(tmux new-window -d -P -F '#{window_id}' -t "${session_name}" \
            -n "${window_name}" -c "${target_directory}")
    else
        session_name=$(basename "${target_directory}")
        window_target=$(tmux new-session -d -P -F '#{window_id}' -s "${session_name}" \
            -n "${window_name}" -c "${target_directory}")
    fi

    configure_window "${window_target}" "${target_directory}" "${workspace_mode}" \
        "${editor_command[@]}"

    tmux select-window -t "${window_target}"
    if [[ "${inside_tmux}" == false ]]; then
        tmux attach-session -t "${session_name}"
    fi
}

main "$@"

#!/usr/bin/env bash
# Launch simple image-based Development Containers with Podman.
set -euo pipefail

readonly PROGRAM_NAME="${0##*/}"
readonly VERSION="1.0.0"

die() {
    printf '%s: %s\n' "${PROGRAM_NAME}" "$*" >&2
    exit 1
}

usage() {
    cat <<EOF
Usage:
  ${PROGRAM_NAME} [-h|--help] [-v|--version] ls
  ${PROGRAM_NAME} [-h|--help] [-v|--version] up <container>

Commands:
  ls              List Development Containers in the current or parent directory.
  up <container>  Run a Development Container with Podman.

The current directory is mounted at workspaceFolder from devcontainer.json, or
/workspace/<container> when workspaceFolder is not configured. Only numeric
forwardPorts entries are supported.
EOF
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

validate_json_file() {
    local config_path="$1"

    jq -e 'type == "object"' "${config_path}" >/dev/null \
        || die "invalid devcontainer configuration: ${config_path}"
}

container_name_for() {
    local config_path="$1"
    local fallback_name

    fallback_name="$(basename "$(dirname "${config_path}")")"
    jq -er --arg fallback "${fallback_name}" \
        'if (.name | type) == "string" and (.name | length) > 0 then .name else $fallback end' \
        "${config_path}" \
        || die "could not read container name from: ${config_path}"
}

declare -a CONFIG_PATHS=()
declare -a CONTAINER_NAMES=()

find_containers() {
    local current_devcontainer_dir="${PWD}/.devcontainer"
    local parent_dir
    local parent_devcontainer_dir
    local parent_config_path
    local config_path
    local container_name

    parent_dir="$(dirname "${PWD}")"
    parent_devcontainer_dir="${parent_dir}/.devcontainer"
    parent_config_path="${parent_dir}/devcontainer.json"

    mapfile -d '' -t CONFIG_PATHS < <(
        {
            if [[ -d "${current_devcontainer_dir}" ]]; then
                find "${current_devcontainer_dir}" -type f -name devcontainer.json -print0
            fi
            if [[ "${parent_dir}" != "${PWD}" && -d "${parent_devcontainer_dir}" ]]; then
                find "${parent_devcontainer_dir}" -type f -name devcontainer.json -print0
            fi
            if [[ "${parent_dir}" != "${PWD}" && -f "${parent_config_path}" ]]; then
                printf '%s\0' "${parent_config_path}"
            fi
        } | sort -z
    )
    ((${#CONFIG_PATHS[@]} > 0)) || die "no devcontainer.json files found in: ${PWD} or ${parent_dir}"

    CONTAINER_NAMES=()
    for config_path in "${CONFIG_PATHS[@]}"; do
        validate_json_file "${config_path}"
        container_name="$(container_name_for "${config_path}")"
        [[ "${container_name}" != *$'\n'* ]] \
            || die "container name must not contain a newline: ${config_path}"
        CONTAINER_NAMES+=("${container_name}")
    done

    for ((i = 0; i < ${#CONTAINER_NAMES[@]}; i++)); do
        for ((j = i + 1; j < ${#CONTAINER_NAMES[@]}; j++)); do
            [[ "${CONTAINER_NAMES[i]}" != "${CONTAINER_NAMES[j]}" ]] \
                || die "duplicate container name: ${CONTAINER_NAMES[i]}"
        done
    done
}

list_containers() {
    local container_name

    find_containers
    for container_name in "${CONTAINER_NAMES[@]}"; do
        printf '%s\n' "${container_name}"
    done
}

run_container() {
    local requested_name="$1"
    local config_path=""
    local i
    local image
    local workspace_folder
    local port
    local env_name
    local env_value
    declare -a podman_args=(run --rm -it)

    require_command podman
    find_containers

    for ((i = 0; i < ${#CONTAINER_NAMES[@]}; i++)); do
        if [[ "${CONTAINER_NAMES[i]}" == "${requested_name}" ]]; then
            config_path="${CONFIG_PATHS[i]}"
            break
        fi
    done
    [[ -n "${config_path}" ]] || die "container not found: ${requested_name}"

    image="$(jq -er '.image | select(type == "string" and length > 0)' "${config_path}")" \
        || die "container has no non-empty string image: ${config_path}"

    workspace_folder="$(jq -er \
        --arg default "/workspace/${requested_name}" \
        'if .workspaceFolder == null then $default
         elif (.workspaceFolder | type) == "string" and (.workspaceFolder | length) > 0 then .workspaceFolder
         else error("workspaceFolder must be a non-empty string") end' \
        "${config_path}")" \
        || die "invalid workspaceFolder: ${config_path}"
    [[ "${workspace_folder}" == /* ]] \
        || die "workspaceFolder must be an absolute path: ${config_path}"

    jq -e '
        if .containerEnv == null then true
        elif (.containerEnv | type) != "object" then false
        else all(.containerEnv[]; type == "string") end
    ' "${config_path}" >/dev/null \
        || die "containerEnv must be an object with string values: ${config_path}"
    while IFS=$'\t' read -r env_name env_value; do
        podman_args+=(--env "${env_name}=${env_value}")
    done < <(jq -r '.containerEnv // {} | to_entries[] | [.key, .value] | @tsv' "${config_path}")

    jq -e '
        if .forwardPorts == null then true
        elif (.forwardPorts | type) != "array" then false
        else all(.forwardPorts[]; type == "number" and floor == . and . >= 1 and . <= 65535) end
    ' "${config_path}" >/dev/null \
        || die "forwardPorts must be an array of numeric ports from 1 through 65535: ${config_path}"
    while IFS= read -r port; do
        [[ -n "${port}" ]] || continue
        podman_args+=(--publish "${port}:${port}")
    done < <(jq -r '.forwardPorts // [] | .[]' "${config_path}")

    if ! podman image ls --format '{{.Repository}}:{{.Tag}}' | grep -Fqx -- "${image}"; then
        die "image does not exist locally: ${image}"
    fi

    podman_args+=(-v "${PWD}:${workspace_folder}:Z" "${image}")
    exec podman "${podman_args[@]}"
}

main() {
    local parsed
    local action

    require_command getopt
    require_command find
    require_command grep
    require_command jq
    require_command sort

    parsed="$(getopt --options hv --longoptions help,version --name "${PROGRAM_NAME}" -- "$@")" \
        || {
            usage >&2
            exit 2
        }
    eval set -- "${parsed}"
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

    (($# >= 1)) || {
        usage >&2
        exit 2
    }
    action="$1"
    shift

    case "${action}" in
        ls)
            (($# == 0)) || die "ls does not accept arguments"
            list_containers
            ;;
        up)
            (($# == 1)) || die "up requires exactly one container name"
            run_container "$1"
            ;;
        *)
            die "unknown command: ${action}"
            ;;
    esac
}

main "$@"

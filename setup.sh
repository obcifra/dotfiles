#!/usr/bin/env bash

set -e

DOTFILES_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
UNINSTALL=0

# Load common script functions and variables
# shellcheck disable=SC1091
source "${DOTFILES_ROOT}/tools/common.sh"

show_help() {
  echo "Usage: setup [options] <prefix>"
  echo
  echo "Options:"
  echo "  -h        Show this help message"
  echo "  -u        Uninstall instead of install"
  echo
  echo "Arguments:"
  echo "  <prefix>  Required. Path to install/uninstall to/from."
}

# Creates symlinks to dotfiles in the prefix directory.
# Backs up any existing dotfiles with a ".old" suffix.
syminstall () {
  local _source="${1}"
  local _prefix="${2}"
  local _target="${3}"

  if [ -L "${_prefix}/${_target}" ]; then
    ln -sfn "${DOTFILES_ROOT}/${_source}" "${_prefix}/${_target}"
  else
    if [ -f "${_prefix}/${_target}" ]; then
      mv "${_prefix}/${_target}" "${_prefix}/${_target}.old"
      print_success "Create backup of ${_prefix}/${_target}"
    fi
    ln -s "${DOTFILES_ROOT}/${_source}" "${_prefix}/${_target}"
  fi
  print_success "Create link ${_prefix}/${_target}"
}

# Removes symlinks to dotfiles in the prefix directory.
# Restores any existing dotfiles with a ".old" suffix.
symremove () {
  local _source="${1}"
  local _prefix="${2}"
  local _target="${3}"

  if [ -L "${_prefix}/${_target}" ]; then
    rm "${_prefix}/${_target}"
    print_success "Remove link ${_prefix}/${_target}"
  fi

  # Restore any ".old" dotfiles
  if [ -f "${_prefix}/${_target}.old" ]; then
    mv "${_prefix}/${_target}.old" "${_prefix}/${_target}"
    print_success "Restore backup of ${_prefix}/${_target}"
  fi
}

# Convenience function to install dotfiles.
dotinstall () {
  local _source="${1}"
  local _prefix="${2}"
  local _target=".${_source#*.}"

  syminstall "${_source}" "${_prefix}" "${_target}"
}

# Convenience function to remove dotfiles.
dotremove () {
  local _source="${1}"
  local _prefix="${2}"
  local _target=".${_source#*.}"

  symremove "${_source}" "${_prefix}" "${_target}"
}

uninstall() {
  local prefix=$1
  print_status "Uninstalling from $prefix..."

  # Bash
  dotremove "bash/common.bash_profile" "${prefix}" # .bash_profile
  dotremove "bash/common.bashrc"       "${prefix}" # .bashrc
  dotremove "other/common.inputrc"     "${prefix}" # .inputrc

  # Git
  dotremove "git/common.gitconfig"     "${prefix}" # .gitconfig

  # Tmux
  dotremove "tmux/common.tmux.conf"    "${prefix}" # .tmux.conf

  # Vim
  dotremove "vim/common.vimrc"         "${prefix}" # .vimrc
  dotremove "vim/common.vim"           "${prefix}" # .vim

  # Neovim
  rm -f "${prefix}/.config/nvim/init.vim"
  print_success "Remove ${prefix}/.config/nvim/init.vim"

  # zsh
  dotremove "zsh/common.zshrc"         "${prefix}" # .zshrc

  # Mutt
  dotremove "mutt/common.muttrc"       "${prefix}" # .muttrc

  # GPG
  symremove "gpg/gpg.conf" "${prefix}/.gnupg" "gpg.conf"

  # Agents
  symremove "agents" "${prefix}" # .agents

}

install() {
  local prefix=$1
  print_status "Installing to $prefix..."

  # Bash
  dotinstall "bash/common.bash_profile" "${prefix}" # .bash_profile
  dotinstall "bash/common.bashrc"       "${prefix}" # .bashrc
  dotinstall "other/common.inputrc"     "${prefix}" # .inputrc

  # Git
  if command_exists git; then
    dotinstall "git/common.gitconfig"   "${prefix}" # .gitconfig
  else
    print_warning "Git is not installed; skipping .gitconfig setup."
  fi

  # Tmux
  if command_exists tmux; then
    dotinstall "tmux/common.tmux.conf"  "${prefix}" # .tmux.conf
  else
    print_warning "Tmux is not installed; skipping .tmux.conf setup."
  fi

  # Vim
  if command_exists vim; then
    dotinstall "vim/common.vimrc"       "${prefix}" # .vimrc
    dotinstall "vim/common.vim"         "${prefix}" # .vim
  else
    print_warning "Vim is not installed; skipping .vimrc and .vim setup."
  fi

  # Neovim
  if command_exists nvim; then
    mkdir -p "${prefix}/.config/nvim"
    {
      echo "set runtimepath^=${prefix}/.vim runtimepath+=${prefix}/.vim/after"
      echo "let &packpath = &runtimepath"
      echo "source ${prefix}/.vimrc"
    } > "${prefix}/.config/nvim/init.vim"
    print_success "Create file ${prefix}/.config/nvim/init.vim"
  else
    print_warning "Neovim is not installed; skipping init.vim setup."
  fi

  # zsh
  if command_exists zsh; then
    dotinstall "zsh/common.zshrc"       "${prefix}" # .zshrc
  else
    print_warning "Zsh is not installed; skipping .zshrc setup."
  fi

  # Mutt
  if command_exists mutt; then
    dotinstall "mutt/common.muttrc"     "${prefix}" # .muttrc
  else
    print_warning "Mutt is not installed; skipping .muttrc setup."
  fi

  # GPG
  if command_exists gpg; then
    mkdir -p "${prefix}/.gnupg"
    chmod 700 "${prefix}/.gnupg"
    syminstall "gpg/gpg.conf" "${prefix}/.gnupg" "gpg.conf"
  else
    print_warning "GPG is not installed; skipping gpg.conf setup."
  fi

  # Agents
  dotinstall "agents" "${prefix}" # .agents
}

# Parse options
while getopts ":hu" opt; do
  case $opt in
    h)
      show_help
      exit 0
      ;;
    u)
      UNINSTALL=1
      ;;
    \?)
      print_error "Invalid option: -$OPTARG" >&2
      show_help
      exit 1
      ;;
  esac
done

# Shift positional arguments
shift $((OPTIND -1))

# Ensure <prefix> is provided
if [ -z "$1" ]; then
  print_error "<prefix> argument is required." >&2
  show_help
  exit 1
fi

# Check if the prefix is a valid path
if [ ! -d "$1" ]; then
  print_error "'$1' is not a valid directory path." >&2
  exit 1
fi

# Run install or uninstall
if [ "$UNINSTALL" -eq 1 ]; then
  uninstall "$1"
else
  install "$1"
fi

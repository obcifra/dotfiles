#!/bin/env bash
# setup_venv.sh: Set up Python virtual environment and install requirements for playbook

set -e

VENV_DIR=".venv-dotfiles"
REQ_FILE="requirements.txt"

# Use system python3
PYTHON_BIN="python3"

# Ensure pip is installed and upgraded in the system Python
$PYTHON_BIN -m ensurepip --upgrade

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    $PYTHON_BIN -m venv "$VENV_DIR"
fi

echo "Activating virtual environment..."
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

echo "Installing requirements from $REQ_FILE..."
pip install --upgrade pip
pip install -r "$REQ_FILE"

echo "Virtual environment setup complete. To activate, run:"
echo "  source $VENV_DIR/bin/activate"

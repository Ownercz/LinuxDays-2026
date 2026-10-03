#!/usr/bin/env bash
set -euo pipefail

echo "==============================================================="
echo "Welcome to the LinuxDays 2026 Ansible workshop"
echo "Preparing environment..."
echo "==============================================================="

# Config
VENV_DIR="/opt/python-venv-ansible"
ANSIBLE_VERSION="11.1.0"
ADDED_TO_BASHRC=0

# Basic OS check (non-fatal)
if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|debian) ;;
    *) echo "Notice: This script is designed for Debian/Ubuntu. Continuing..." ;;
  esac
fi

echo "[1/6] Installing system packages (python3, python3-venv, wget, gpg)..."
sudo apt-get update -y
sudo apt-get install -y python3 python3-venv python3-pip wget gpg

echo "[2/6] Installing Visual Studio Code"
sudo install -d -m 0755 /etc/apt/keyrings
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y code

echo "[3/6] Creating virtualenv: $VENV_DIR"
if [ ! -d "$VENV_DIR" ]; then
  sudo mkdir -p "$VENV_DIR"
  sudo chown "$(id -u)":"$(id -g)" "$VENV_DIR"
  python3 -m venv "$VENV_DIR"
else
  echo "Virtualenv already exists, skipping."
fi

echo "[4/6] Activating virtualenv"
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

echo "[5/6] Upgrading pip and installing Ansible $ANSIBLE_VERSION"
python -m pip install --upgrade pip
if ! python -m pip install "ansible==${ANSIBLE_VERSION}"; then
  echo "Warning: Installation of ansible==${ANSIBLE_VERSION} failed. Trying latest available version..."
  python -m pip install ansible
fi
echo "Installing Python 'requests' library"
python -m pip install requests

echo "[6/6] Checking versions"
echo -n "Python: "; python --version
echo -n "Pip:    "; pip --version
echo -n "Ansible:"; ansible --version | head -n1 || echo " Ansible is not available."

echo "[6/6] Adding auto-activation to ~/.bashrc (if missing)"
BASHRC="${HOME}/.bashrc"
ACTIVATE_LINE="source $VENV_DIR/bin/activate  # Ansible workshop venv"
if ! grep -Fq "$VENV_DIR/bin/activate" "$BASHRC" 2>/dev/null; then
  {
    echo ""
    echo "# Auto-activate Ansible workshop virtualenv (added $(date +%Y-%m-%d))"
    echo "$ACTIVATE_LINE"
  } >> "$BASHRC"
  ADDED_TO_BASHRC=1
  echo "Line added."
else
  echo "Line already exists, not added."
fi

echo
echo "==============================================================="
echo "Installation finished."
if [ "$ADDED_TO_BASHRC" -eq 1 ]; then
  echo "Automatic environment activation has been added to ~/.bashrc."
else
  echo "Automatic activation was already configured."
fi
echo "Manual activation (if you need it in another shell):"
echo "  source $VENV_DIR/bin/activate"
echo
echo "To disable automatic activation, remove the line with:"
echo "  $VENV_DIR/bin/activate from ~/.bashrc"
echo
echo "LinuxDays 2026 - Ansible Workshop"
echo "==============================================================="
# Ensure virtualenv stays active in current shell if script was sourced
if [ "${BASH_SOURCE[0]:-}" != "$0" ]; then
  # shell is sourcing this script
  # Re-source to be explicit
  # shellcheck disable=SC1090
  source "$VENV_DIR/bin/activate"
  echo "Virtualenv is now active in this shell."
else
  echo
  echo "To activate the virtualenv in your current shell now run:"
  echo "  source \"$0\""
fi

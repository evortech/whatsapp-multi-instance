#!/usr/bin/env bash
# Installs dependencies (docker, adb, scrcpy, unzip) and the `wam` command on Ubuntu/Debian.
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"; BIN="$HOME/.local/bin"

echo "[1/4] Installing packages (needs sudo) ..."
sudo apt-get update -y
sudo apt-get install -y docker.io adb scrcpy unzip curl
sudo systemctl enable --now docker

echo "[2/4] Adding $USER to the docker group ..."
sudo usermod -aG docker "$USER"

echo "[3/4] Checking kernel support for Android (binder) ..."
if grep -q binder /proc/filesystems; then echo "  binder: OK"
elif sudo modprobe binder_linux devices="binder,hwbinder,vndbinder" 2>/dev/null; then echo "  binder: loaded module"
else echo "  WARNING: no binder support in kernel $(uname -r). See docs/TROUBLESHOOTING.md"; fi

echo "[4/4] Installing wam ..."
mkdir -p "$BIN" "$HOME/redroid"
install -m 755 "$HERE/bin/wam" "$BIN/wam"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "  Add to PATH: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc";; esac

echo; echo "Done. LOG OUT AND BACK IN (or run: newgrp docker) so docker works without sudo."
echo "Then:  wam doctor"

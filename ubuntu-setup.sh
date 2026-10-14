#!/usr/bin/env bash
#
# ubuntu-setup.sh – opsætter en frisk Ubuntu-installation
# Kræver: køres med sudo, og apt-listen i apps.txt
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Kør scriptet som root: sudo ./ubuntu-setup.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> Opdaterer systemet..."
apt update && apt upgrade -y

echo ">>> Installerer apps fra apps.txt..."
xargs -a "$SCRIPT_DIR/apps.txt" apt install -y

echo ">>> Installerer flatpak + GNOME Software med flatpak-support..."
apt install -y flatpak gnome-software gnome-software-plugin-flatpak

echo ">>> Tilføjer Flathub..."
flatpak remote-add --if-not-exists flathub \
  https://dl.flathub.org/repo/flathub.flatpakrepo

echo ">>> Installerer flatpak-apps fra flatpak-apps.txt..."
xargs -a "$SCRIPT_DIR/flatpak-apps.txt" flatpak install -y flathub

echo ">>> Færdig! Genstart evt. maskinen, så flatpak-integration er klar."

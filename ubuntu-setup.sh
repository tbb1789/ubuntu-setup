#!/usr/bin/env bash
#
# ubuntu-setup.sh – opsætter en frisk Ubuntu-installation
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Kør scriptet som root: sudo ./ubuntu-setup.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

### FASE 1: SYSTEM ###
echo ">>> Opdaterer systemet..."
apt update && apt upgrade -y

echo ">>> Aktiverer repos og arkitekturer..."
add-apt-repository -y multiverse   # Steam + codecs
dpkg --add-architecture i386       # 32-bit til Steam/Proton
add-apt-repository -y ppa:kisak/kisak-mesa          # nyere Mesa (AMD/Intel)
add-apt-repository -y ppa:graphics-drivers/ppa      # nyeste NVIDIA-drivere
apt update

echo ">>> Installerer systemværktøjer..."
apt install -y flatpak gnome-software gnome-software-plugin-flatpak

echo ">>> Tilføjer Flathub..."
flatpak remote-add --if-not-exists --system flathub \
  https://dl.flathub.org/repo/flathub.flatpakrepo

echo ">>> Opdaterer grafikdrivere (Mesa/NVIDIA)..."
apt full-upgrade -y    # trækker nye Mesa/NVIDIA-pakker fra PPA'erne

### FASE 2: APPS ###
echo ">>> Installerer apps fra apps.txt..."
xargs -a "$SCRIPT_DIR/apps.txt" apt install -y

echo ">>> Installerer flatpak-apps fra flatpak-apps.txt..."
xargs -a "$SCRIPT_DIR/flatpak-apps.txt" flatpak install --system -y flathub

echo ">>> Færdig! Genstart maskinen, så nye drivere aktiveres."

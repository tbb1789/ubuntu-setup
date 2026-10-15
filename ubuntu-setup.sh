#!/usr/bin/env bash
#
# ubuntu-setup.sh – opsætter en frisk Ubuntu-installation
# Kræver: køres med sudo, apps.txt og flatpak-apps.txt i samme mappe
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
add-apt-repository -y multiverse
dpkg --add-architecture i386
apt update

echo ">>> Grafik-drivere: tilføjer PPA'er hvor de findes..."
source /etc/os-release
case "$VERSION_CODENAME" in
  noble)    # Ubuntu 24.04 LTS – PPA'er testet og virkende
    add-apt-repository -y ppa:kisak/kisak-mesa
    add-apt-repository -y ppa:graphics-drivers/ppa
    apt update
    echo ">>> Opdaterer grafikdrivere fra PPA'er..."
    apt full-upgrade -y
    ;;
  *)
    # 26.04 / 26.10 m.fl. – PPA'erne er ikke (endnu) bygget til disse udgaver.
    # Standard-Mesa/NVIDIA i Ubuntus egne repos er her allerede opdaterede.
    echo "    Springer PPA'er over ($VERSION_CODENAME) – bruger standard-drivere"
    ;;
esac

echo ">>> Installerer flatpak + GNOME Software..."
apt install -y flatpak gnome-software gnome-software-plugin-flatpak

echo ">>> Tilføjer Flathub..."
flatpak remote-add --if-not-exists --system flathub \
  https://dl.flathub.org/repo/flathub.flatpakrepo

### FASE 2: APPS ###
echo ">>> Installerer apps fra apps.txt..."
xargs -a "$SCRIPT_DIR/apps.txt" apt install -y

echo ">>> Installerer flatpak-apps fra flatpak-apps.txt..."
xargs -a "$SCRIPT_DIR/flatpak-apps.txt" flatpak install --system -y flathub

echo ">>> Færdig! Genstart maskinen, så eventuelle driver-opdateringer aktiveres."

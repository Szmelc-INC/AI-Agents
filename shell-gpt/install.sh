#!/usr/bin/env bash
set -e

echo "[*] Installing Shell-GPT..."

# Detect package manager
if command -v pacman >/dev/null 2>&1; then
    echo "[*] Arch Linux detected. Trying to install from AUR..."
    if command -v yay >/dev/null 2>&1; then
        yay -S --noconfirm shell-gpt
    elif command -v paru >/dev/null 2>&1; then
        paru -S --noconfirm shell-gpt
    else
        echo "[!] No AUR helper (yay/paru) found. Falling back to pipx..."
        pipx install shell-gpt
    fi

elif command -v apt >/dev/null 2>&1; then
    echo "[*] Debian/Ubuntu detected. Installing dependencies..."
    sudo apt update
    sudo apt install -y python3-pip pipx
    pipx install shell-gpt

elif command -v dnf >/dev/null 2>&1; then
    echo "[*] Fedora detected. Installing dependencies..."
    sudo dnf install -y python3-pip pipx
    pipx install shell-gpt

elif command -v zypper >/dev/null 2>&1; then
    echo "[*] openSUSE detected. Installing dependencies..."
    sudo zypper install -y python3-pip python3-pipx
    pipx install shell-gpt

else
    echo "[!] Could not detect supported package manager. Using pipx..."
    pipx install shell-gpt
fi

echo "[*] Shell-GPT installation complete."
echo "    Run: sgpt \"your prompt here\""

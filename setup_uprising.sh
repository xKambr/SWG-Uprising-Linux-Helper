#!/usr/bin/env bash
set -euo pipefail

echo "=========================================================="
echo "          SWG Uprising - Environment Setup                "
echo "=========================================================="

detect_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Dependency Checks
if ! detect_cmd python3; then
    echo "Error: Python 3 is required."
    exit 1
fi

if ! detect_cmd wine; then
    echo "Notice: Wine was not found."
    if detect_cmd pacman; then
        echo "Installing wine via pacman..."
        sudo pacman -S --needed --noconfirm wine
    elif detect_cmd apt-get; then
        sudo apt-get update && sudo apt-get install -y wine
    elif detect_cmd dnf; then
        sudo dnf install -y wine
    else
        echo "Please install Wine manually and rerun this script."
        exit 1
    fi
fi

# 2. Directory Resolution
DEFAULT_DIR="$HOME/Games/SWG-Uprising"
echo ""
read -rp "Enter Wine prefix destination path [$DEFAULT_DIR]: " INSTALL_DIR
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_DIR}"

WINE_PREFIX="$INSTALL_DIR"
CLIENT_DIR="$INSTALL_DIR/drive_c/users/$USER/AppData/Local/Uprising/Client"

mkdir -p "$CLIENT_DIR/.uprising/manifests"
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/Desktop"

# 3. Wine Prefix Setup & Registry Override
echo "==> Initializing Wine prefix..."
WINEPREFIX="$WINE_PREFIX" wineboot -u >/dev/null 2>&1 || true

echo "==> Setting native dinput8 DLL override..."
WINEPREFIX="$WINE_PREFIX" wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "dinput8" /d "native,builtin" /f >/dev/null 2>&1 || true

# 4. Optional Base Media Extraction
if [ -f "./swg_setup.sh" ]; then
    echo ""
    read -rp "Do you want to extract retail ISOs using swg_setup.sh now? [y/N] " extract_choice
    if [[ "$extract_choice" =~ ^[Yy]$ ]]; then
        chmod +x ./swg_setup.sh
        ./swg_setup.sh "$CLIENT_DIR"
    fi
fi

# 5. Install Launcher Script
if [ ! -f "launch_uprising.py" ]; then
    echo "Error: launch_uprising.py was not found in the current directory."
    exit 1
fi

echo "==> Installing launcher script to client directory..."
cp launch_uprising.py "$CLIENT_DIR/launch_uprising.py"
chmod +x "$CLIENT_DIR/launch_uprising.py"

# 6. Terminal Detection & Desktop Shortcuts
TERM_BIN=""
for t in alacritty kitty foot konsole gnome-terminal xfce4-terminal; do
    if detect_cmd "$t"; then
        TERM_BIN="$t"
        break
    fi
done

if [ -z "$TERM_BIN" ]; then
    EXEC_CMD="/usr/bin/python3 \"$CLIENT_DIR/launch_uprising.py\""
    TERMINAL_SETTING="true"
else
    case "$TERM_BIN" in
        konsole)
            EXEC_CMD="konsole -e /usr/bin/python3 \"$CLIENT_DIR/launch_uprising.py\""
            ;;
        *)
            EXEC_CMD="$TERM_BIN -e /usr/bin/python3 \"$CLIENT_DIR/launch_uprising.py\""
            ;;
    esac
    TERMINAL_SETTING="false"
fi

echo "==> Creating desktop shortcuts using ${TERM_BIN:-system default terminal}..."
DESKTOP_FILE="$HOME/.local/share/applications/swg-uprising.desktop"
cat << EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=SWG Uprising
Comment=Star Wars Galaxies Uprising
Path=$CLIENT_DIR
Exec=$EXEC_CMD
Terminal=$TERMINAL_SETTING
Type=Application
Categories=Game;
EOF

chmod +x "$DESKTOP_FILE"
cp "$DESKTOP_FILE" "$HOME/Desktop/swg-uprising.desktop"
chmod +x "$HOME/Desktop/swg-uprising.desktop"

if detect_cmd update-desktop-database; then
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
fi

echo ""
echo "=========================================================="
echo "Installation Finished!"
echo "Destination: $CLIENT_DIR"
echo "Launch with your desktop shortcut or run:"
echo "$CLIENT_DIR/launch_uprising.py"
echo "=========================================================="

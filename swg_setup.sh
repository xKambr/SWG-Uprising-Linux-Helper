#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-}"

if [ -z "$TARGET_DIR" ]; then
    DEFAULT_DIR="$HOME/Games/SWG-Uprising/drive_c/users/$USER/AppData/Local/Uprising/Client"
    read -rp "Enter destination Client directory [$DEFAULT_DIR]: " TARGET_DIR
    TARGET_DIR="${TARGET_DIR:-$DEFAULT_DIR}"
fi

mkdir -p "$TARGET_DIR"

# Check for 7z dependency
SEVENZIP=""
for z in 7z 7za; do
    if command -v "$z" >/dev/null 2>&1; then
        SEVENZIP="$z"
        break
    fi
done

if [ -z "$SEVENZIP" ]; then
    echo "==> 7-Zip is required to extract ISO and CAB archives."
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm p7zip
        SEVENZIP="7z"
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y p7zip-full
        SEVENZIP="7z"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y p7zip p7zip-plugins
        SEVENZIP="7z"
    else
        echo "Error: Please install p7zip manually and rerun."
        exit 1
    fi
fi

# Locate Disc ISOs
echo "==> Searching for SWG installation ISOs..."
prompt_iso() {
    local num="$1"
    local found
    found=$(find . -maxdepth 2 -iname "*galaxies*$num*.iso" -o -iname "*disc*$num*.iso" 2>/dev/null | head -n 1)
    if [ -z "$found" ] || [ ! -f "$found" ]; then
        read -rp "Enter path to Disc $num ISO: " found
    fi
    if [ ! -f "$found" ]; then
        echo "Error: File not found: $found"
        exit 1
    fi
    echo "$found"
}

DISC1=$(prompt_iso 1)
DISC2=$(prompt_iso 2)
DISC3=$(prompt_iso 3)

TMP_EXTRACT="/tmp/swg_disc_extract_$$"
mkdir -p "$TMP_EXTRACT"
trap 'rm -rf "$TMP_EXTRACT"' EXIT

echo "==> Extracting ISO files..."
"$SEVENZIP" x -y -o"$TMP_EXTRACT/d1" "$DISC1" >/dev/null
"$SEVENZIP" x -y -o"$TMP_EXTRACT/d2" "$DISC2" >/dev/null
"$SEVENZIP" x -y -o"$TMP_EXTRACT/d3" "$DISC3" >/dev/null

echo "==> Extracting game archives from InstallShield cabinets..."
find "$TMP_EXTRACT" -type f -iname "*.cab" -exec "$SEVENZIP" e -y -o"$TMP_EXTRACT/assets" {} \; >/dev/null 2>&1 || true

echo "==> Moving .tre archives to $TARGET_DIR..."
found_tre=0
while IFS= read -r file; do
    fname=$(basename "$file")
    lower_fname=$(echo "$fname" | tr '[:upper:]' '[:lower:]')
    cp -u "$file" "$TARGET_DIR/$lower_fname"
    found_tre=$((found_tre + 1))
done < <(find "$TMP_EXTRACT" -type f -iname "*.tre")

echo "Successfully extracted $found_tre .tre archives."

# Provide base configuration if missing
CFG_FILE="$TARGET_DIR/swg_client.cfg"
if [ ! -f "$CFG_FILE" ]; then
    echo "==> Generating base swg_client.cfg..."
    cat << 'EOF' > "$CFG_FILE"
[SharedFile]
    searchPath01=.

[ClientGame]
    autoPlayerAcceptedEula=1
    preApprovedServer=1

[ClientGraphics]
    useHardwareMouseCursor=1
EOF
fi

echo ""
echo "====================================================================="
echo "Extraction complete! Files placed in: $TARGET_DIR"
echo "====================================================================="

# Star Wars Galaxies: Uprising — Linux Client Setup & Launcher

A lightweight, native Linux setup and launcher suite for **Star Wars Galaxies: Uprising**. 

This toolset bypasses the official Windows Electron installer and launcher entirely to eliminate common Wine friction points: Wine UDP socket stalls during login handshakes, broken background NSIS update loops, and crashing `powershell.exe`/JSON sub-processes.

---

## Included Components

| File | Purpose |
| :--- | :--- |
| `setup_uprising.sh` | Automated environment installer: builds the isolated Wine prefix, applies registry overrides, and registers desktop application shortcuts. |
| `swg_setup.sh` | *(Optional)* Direct asset extractor: natively pulls the 15 base `.tre` game archives from retail ISOs (`GALAXIES1.iso`–`3`) using 7-Zip. |
| `launch_swguprising.py` | Standalone Python client: runs differential HTTPS manifest updates, performs the SOE UDP login handshake natively, and starts `SWGEmu.exe` synchronously in Wine. |

---

## Prerequisites

Before starting, ensure you have:
1. **Linux Distribution:** Arch / CachyOS, SteamOS, Bazzite, Fedora, Ubuntu/Debian, or openSUSE.
2. **System Packages:**
   * `wine` (or `wine-staging` / `wine-cachyos`)
   * `python3`
   * `p7zip` (only required if extracting retail ISOs with `swg_setup.sh`)
   * A terminal emulator (`alacritty`, `kitty`, `foot`, `konsole`, `gnome-terminal`, or `xfce4-terminal`)
3. **SWG Base Game Files:**
   * Either original retail installation media (`GALAXIES1.iso`, `GALAXIES2.iso`, `GALAXIES3.iso`) or pre-extracted retail TRE files (`bottom.tre`, `data_sku0_00.tre` through `data_sku0_14.tre`).
   * A clean `SWGEmu.exe` executable.

> **Note:** `setup_uprising.sh` will automatically detect your package manager (`pacman`, `apt`, `dnf`, `zypper`) and prompt to install missing core packages if permitted.

---

## Installation

### Step 1: Clone the Repository & Set Permissions

```bash
git clone [https://github.com/xKambr/SWG-Uprising-Linux-Helper.git](https://github.com/xKambr/SWG-Uprising-Linux-Helper.git)
cd SWG-Uprising-Linux-Helper
chmod +x setup_uprising.sh swg_setup.sh

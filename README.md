# SWG Uprising — Linux Suite

A lightweight, portable setup automation suite and native Linux launcher for **Star Wars Galaxies: Uprising**. 

This project bypasses the Windows Electron launcher completely, avoiding common Wine issues such as stuck NSIS updates, JSON parser errors with `powershell.exe`, and stalled UDP socket authentication handshakes.

---

## Features

- **Automated Base Asset Extraction (`swg_setup.sh`)**: Extracts original retail `.tre` archives directly from `GALAXIES1.iso`, `GALAXIES2.iso`, and `GALAXIES3.iso` using 7-Zip without executing the legacy InstallShield setup.
- **Prefix & Shortcut Automation (`setup_uprising.sh`)**: Builds an isolated Wine prefix, registers required native DLL overrides (`dinput8`), links game directories, and generates auto-closing desktop shortcuts.
- **Native Launcher & Differential Sync (`launch_uprising.py`)**: Checks server release manifests against `live-channel.json`, downloads missing/modified assets over HTTPS, performs clean SOE UDP packet authentication natively, and runs the client smoothly through Wine.

---

## Project Structure

```text
swg-uprising-linux/
├── setup_uprising.sh       # Main environment configuration & orchestrator
├── swg_setup.sh            # Standalone ISO/CAB asset extraction script
├── launch_uprising.py      # Standalone updater, authenticator & Wine launcher
├── LICENSE                 # MIT License
└── README.md               # Documentation and usage guide
```

---

## Prerequisites

- **Python 3**
- **Wine** (or `wine-staging`)
- **p7zip** / **7z** (only required if extracting base archives from retail ISOs)
- Any supported terminal emulator (`alacritty`, `kitty`, `foot`, `konsole`, `gnome-terminal`, or `xfce4-terminal`)

The setup script checks for these packages and can prompt your distribution's package manager (`pacman`, `apt`, `dnf`, `zypper`) to install any missing tools.

---

## Quick Start

### 1. Clone or Download

Clone this repository or download the release archive:

```bash
git clone https://github.com/<your-username>/swg-uprising-linux.git
cd swg-uprising-linux
chmod +x setup_uprising.sh swg_setup.sh launch_uprising.py
```

### 2. Run the Setup Script

```bash
./setup_uprising.sh
```

During setup, you will be prompted to:
1. Specify your installation target directory (Default: `~/Games/SWG-Uprising`).
2. Optionally extract base game assets if you have your retail ISOs present.
3. Automatically create application entries and desktop shortcuts.

### 3. Provide Base Game Assets (If Not Extracting ISOs)

If you already have your base game files extracted, place the vanilla `.tre` files (`bottom.tre`, `data_sku0_00.tre` through `data_sku0_14.tre`) and a clean `SWGEmu.exe` into:

```text
~/Games/SWG-Uprising/drive_c/users/<USER>/AppData/Local/Uprising/Client/
```

*(You do not need to download custom Uprising files or `dinput8.dll` manually; the launcher pulls these automatically).*

### 4. Launch the Game

- Double-click the **SWG Uprising** shortcut on your Desktop or in your application launcher.
- Alternatively, launch directly via terminal:
  ```bash
  ~/Games/SWG-Uprising/drive_c/users/$USER/AppData/Local/Uprising/Client/launch_uprising.py
  ```

---

## Optional: Storing Login Credentials

To bypass entering your account credentials on every launch:

1. Open `launch_uprising.py` in your text editor:
   ```bash
   nano ~/Games/SWG-Uprising/drive_c/users/$USER/AppData/Local/Uprising/Client/launch_uprising.py
   ```
2. Locate the following lines in `def main()`:
   ```python
   username = input("Username: ").strip()
   password = getpass.getpass("Password: ")
   ```
3. Update them with your credentials:
   ```python
   username = "YourUsername"
   password = "YourPassword"
   ```

---

## Legal & Disclaimer

This repository contains only automation scripts and network interoperability tooling. It does not distribute, host, or contain any proprietary game assets, retail executables, or copyrighted materials.

- Users must provide their own legitimately acquired retail media of *Star Wars Galaxies* to extract base game archives.
- All game updates and server-specific files are fetched directly from public endpoints operated by the SWG Uprising team.
- This project is an independent community tool and is not affiliated with, endorsed by, or connected to Lucasfilm Games, Sony Online Entertainment, Daybreak Game Company, The Walt Disney Company, or the SWG Uprising server administration.
- All trademarks and copyrights belong to their respective owners.
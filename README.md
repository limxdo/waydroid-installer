# waydroid-installer

This project provides an interactive installer script for installing, configuring, and removing Waydroid on both Debian-based and Arch-based Linux distributions.

The installer simplifies setting up:

- [Waydroid](https://github.com/waydroid/waydroid) (main package)

- [Waydroid Script](https://github.com/casualsnek/waydroid_script) (by casualsnek)

- Waydroid X11 launcher using Weston

Support is currently available for:

**Debian-based systems (Debian, Ubuntu, etc.)**

**Arch-based systems (Arch, Manjaro, etc.)**

> Support for Fedora/RHEL-based distributions is planned in the future.
---

## Usage:
---
### Arch / Arch-based

```bash
git clone https://github.com/limxdo/waydroid-installer.git
cd waydroid-installer/arch-based
./main.sh
```

### Debian / Debian-based

```bash
git clone https://github.com/limxdo/waydroid-installer.git
cd waydroid-installer/debian-based
./main.sh
```

## Requuirements

Before starting the installation, the script will automatically check for essential packages required to continue.

Make sure these packages are already installed to avoid issues:

### Debian-based:
- `python3`

- `python3-venv`

- `git`

- `curl`

- `ca-certificates`

If any of these packages are missing, the script will print a warning.

You can install them manually with:

```bash
sudo apt install python3 python3-venv git curl ca-certificates
```

### Arch-based:

- `base-devel`

- `yay`

To install them manually:

**Arch-based**

```bash
sudo pacman -S base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

**Manjaro**

```bash
sudo pacman -S base-devel yay
```

This check ensures everything is ready before the script starts installing Waydroid and its components.

---


## ⚠️ Important Note

Before running the installer, make sure you're **inside the correct subdirectory** based on your distribution.

For example:

```bash
cd waydroid-installer/debian-based
./main.sh
```

**Running the script from outside its directory (like this 👇) may cause file path issues:**

```bash
./debian-based/main.sh  # ❌ Don't do this
```

**Always enter the subdirectory (`arch-based` or `debian-based`) first, then run `./main.sh.`**

---

## License

This project is licensed under the GNU General Public License v3.0.

You are free to use, modify, and redistribute the code under the terms of this license.
See the LICENSE file for full details.

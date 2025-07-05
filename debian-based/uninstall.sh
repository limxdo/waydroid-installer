#!/bin/bash
# This file is part of waydroid-installer.
# Licensed under the GNU General Public License v3.0
# See the LICENSE file in the root of this repository.

clear

# Keep sudo session alive
# This avoids asking for the password multiple times

if [[ -z "$SUDO_LOOP_PID" ]]; then
    sudo -v || { echo; echo "This script requires sudo privileges."; exit 2; }

    (
        while true; do
            sudo -n true > /dev/null 2>&1
            sleep 180
        done
    ) &
    export SUDO_LOOP_PID=$!
    
    trap "kill $SUDO_LOOP_PID" EXIT
fi

clear

# Available removal options:
# remove_waydroid
# remove_waydroid_x11
# remove_waydroid_script

# Installed Components
echo "Installed Components:"
echo

# Check if Waydroid is installed
if [[ -x /usr/bin/waydroid ]]; then
	echo "Waydroid"
elif [[ ! -x /usr/bin/waydroid ]]; then
    WAYDROID=1
fi

# Check if Waydroid Script is installed
if [[ -d ~/waydroid_script && -x ~/waydroid_script/main.py ]]; then
	echo "Waydroid Script"
elif [[ ! -d ~/waydroid_script ]]; then
    WAYDROIDSC=1
fi

# Check if Waydroid X11 is installed
if [[ -x /usr/bin/waydroid-x11 && -f /usr/share/applications/waydroid-x11.desktop ]]; then
	echo "Waydroid X11"
elif ! [[ -x /usr/bin/waydroid-x11 && -f /usr/share/applications/waydroid-x11.desktop ]]; then
    WAYDROIDX=1
fi

# If nothing is installed
if [[ ! -x /usr/bin/waydroid-x11 && ! -f /usr/share/applications/waydroid-x11.desktop && ! -d ~/waydroid_script && ! -x /usr/bin/waydroid ]]; then
    echo "Nothing installed."
    ALL=1
fi

# Function to remove Waydroid
remove_waydroid() {
    echo "Removing Waydroid..."
    if [[ -x /usr/bin/waydroid ]] && dpkg -s waydroid > /dev/null 2>&1 || [[ ! -x /usr/bin/waydroid ]] && dpkg -s waydroid > /dev/null 2>&1; then
        echo "Removing waydroid files..."
        sudo systemctl stop waydroid-container > /dev/null 2>&1
        sudo systemctl disable waydroid-container > /dev/null 2>&1
        sudo rm -rf ~/.config/waydroid > /dev/null 2>&1
        sudo rm -rf ~/.local/share/waydroid > /dev/null 2>&1
        sudo rm -rf ~/.cache/waydroid > /dev/null 2>&1
        sudo rm -rf ~/.cache/yay/waydroid > /dev/null 2>&1
        sudo rm -rf ~/.local/share/applications/waydroid.* > /dev/null 2>&1
        sudo rm -rf /var/lib/waydroid > /dev/null 2>&1
        sudo rm -rf /etc/waydroid > /dev/null 2>&1
        sudo rm -rf /var/lib/waydroid > /dev/null 2>&1
        sudo rm -rf /etc/waydroid > /dev/null 2>&1
        sudo rm -rf /usr/lib/waydroid > /dev/null 2>&1
        sudo rm -rf /usr/bin/waydroid > /dev/null 2>&1
        sleep 0.75
        echo "Done."
        echo "uninstall waydroid..."
        sudo apt-get purge waydroid -y > /dev/null && echo "Done." || { echo; echo "Package removal failed."; exit 1; }
        sudo rm -rf /usr/share/keyrings/waydroid.gpg /etc/apt/sources.list.d/waydroid.list > /dev/null 2>&1
    else
        sleep 0.75
        echo "Waydroid is not installed. Skipping."
        echo
    fi
}

# Function to remove Waydroid X11
remove_waydroid_x11() {
    echo "Removing Waydroid X11..."
    sleep 1

    if [[ -x /usr/bin/weston ]] && dpkg -s weston > /dev/null 2>&1 || [[ ! -x /usr/bin/weston ]] && dpkg -s weston > /dev/null 2>&1; then
        if ! read -t 90 -p "Do you also want to remove Weston? (y/n): " WESTON; then
            echo
            echo "Error: Invalid input."
            exit 2
        fi

        if [[ "$WESTON" == "y" || -z "$WESTON" ]]; then
            sudo apt-get purge weston -y > /dev/null && echo "Done." || { echo; echo "Weston uninstallation Failed!"; exit 1; }
        elif [[ "$WESTON" == "n" ]]; then
            :
        else
            echo "Error: Invalid input."
            exit 2
        fi
    fi

    if [[ -x /usr/bin/waydroid-x11 && -f /usr/share/applications/waydroid-x11.desktop ]]; then
        echo "removing waydroid x11..."
        sleep 0.50
        sudo rm -rf /usr/bin/waydroid-x11 > /dev/null 2>&1
        sudo rm -rf /usr/share/applications/waydroid-x11.desktop > /dev/null 2>&1
        sleep 0.75
        echo "Done."
    elif [[ ! -x /usr/bin/waydroid-x11 && ! -f /usr/share/applications/waydroid-x11.desktop ]]; then
        sleep 0.75
        echo "Waydroid X11 is not installed. Skipping."
        echo
    fi
}
# Function to remove Waydroid Script
remove_waydroid_script() {
    echo "remove Waydroid Script..."
    if [[ -d ~/waydroid_script ]]; then
        sudo rm -rf ~/waydroid_script && sudo rm -rf ~/.cache/waydroid-script/ > /dev/null 2>&1 && echo "Done." || { echo; echo "Waydroid script uninstallation failed!"; exit 1; }
    elif [[ ! -d ~/waydroid_script ]]; then
        sleep 0.75
        echo "Waydroid Script is not installed. Skipping."
        echo
    else
        echo "Unknown ERROR."
    fi
}

# Main options
echo
echo "What would you like to remove? (1/2/3/4)"
echo
echo "1 - Waydroid"
echo "2 - Waydroid X11"
echo "3 - Waydroid script"
echo "4 - All of the above"
if ! read -t 90 MAINANS; then
    echo
    echo "Timeout! No input received."
    exit 2
fi

    # Check installation to avoid errors:
    if [[ "$MAINANS" == "1" ]]; then
        if [[ -n "$WAYDROID" ]]; then
            echo "Waydroid is already removed."
            exit 2
        fi
    elif [[ "$MAINANS" == "2" ]]; then
        if [[ -n "$WAYDROIDX" ]]; then
            echo "Waydroid X11 is already removed."
            exit 2
        fi
    elif [[ "$MAINANS" == "3" ]]; then
        if [[ -n "$WAYDROIDSC" ]]; then
            echo "Waydroid Script is already removed."
            exit 2
        fi
    elif [[ "$MAINANS" == "4" ]]; then
        if [[ -n "$ALL" ]]; then
            echo "All is already removed."
            exit 2
        fi
    fi

    if [[ "$MAINANS" == "1" ]]; then
        remove_waydroid
    elif [[ "$MAINANS" == "2" ]]; then
        remove_waydroid_x11
    elif [[ "$MAINANS" == "3" ]]; then
        remove_waydroid_script
    elif [[ "$MAINANS" == "4" ]]; then
        remove_waydroid; sleep 0.75
        remove_waydroid_x11; sleep 0.75
        remove_waydroid_script; sleep 0.75
        echo
        echo "All removed."
    elif [[ -z "$MAINANS" || "$MAINANS" != "1" || "$MAINANS" != "2" || "$MAINANS" != "3" || "$MAINANS" != "4" ]]; then
		echo "Error: Invalid input."
		exit 1
	else
		echo "Unknown ERROR!"
		echo "please rerun script."
		exit 1
	fi

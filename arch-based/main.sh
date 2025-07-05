#!/bin/bash
# This file is part of waydroid-installer.
# Licensed under the GNU General Public License v3.0
# See the LICENSE file in the root of this repository.

clear

# Keep sudo session alive to avoid multiple password prompts.
# This loop refreshes sudo every 3 minutes in the background.


if [[ -z "$SUDO_LOOP_PID" ]]; then
    sudo -v || { echo; echo 'the script must be run as sudo!'; echo "Please enter a correct password"; exit 2; }

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

echo
echo "Welcome to the Waydroid installation Script!"
echo "What would you like?: (1/2)"
echo
echo "1 - Install"
echo "2 - Remove"
if ! read -t 90 FIRSTANS; then
    echo
    echo "Timeout! No input received."
    exit 2
fi

    if [[ "$FIRSTANS" == "1" || "$FIRSTANS" == "install" || "$FIRSTANS" == "Install" ]]; then
        ./install.sh
    elif [[ "$FIRSTANS" == "2" || "$FIRSTANS" == "remove" || "$FIRSTANS" == "Remove" ]]; then
        ./uninstall.sh
    else
        echo "Error: Invalid input."
		exit 2
    fi

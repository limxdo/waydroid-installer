#!/bin/bash
# This file is part of waydroid-installer.
# Licensed under the GNU General Public License v3.0
# See the LICENSE file in the root of this repository.

clear

# Keep sudo session alive
# This avoids asking for the password multiple times

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

# Available installation options:
# install_waydroid
# install_waydroid_x11
# install_waydroid_script

# Check for required dependencies:
pacman -Q base-devel > /dev/null 2>&1 || echo "Warning!: Package 'base-devel' not found."
pacman -Q yay > /dev/null 2>&1 || echo "Warning!: Package 'yay' not found."

# List already installed components:
echo
echo "Installed Components:"
echo

# Check if Waydroid is installed
if pacman -Q waydroid > /dev/null 2>&1; then
	echo "Waydroid"
fi

# Check if Waydroid Script is installed
if pacman -Q waydroid-script-git > /dev/null 2>&1; then
	echo "Waydroid Script"
fi

# Check if Waydroid X11 setup is present
if [[ -x /usr/bin/waydroid-x11 && -f /usr/share/applications/waydroid-x11.desktop ]]; then
	echo "Waydroid X11"
fi

# If none of the above are installed
if [[ ! -x /usr/bin/waydroid-x11 && ! -f /usr/share/applications/waydroid-x11.desktop ]] && ! pacman -Q waydroid-script-git > /dev/null 2>&1 && ! pacman -Q waydroid > /dev/null 2>&1; then
    echo "Nothing installed."
fi

# Waydroid Installation Function
install_waydroid() {

    	echo "Select Waydroid system type: (1/2)"
		echo "1 - VANILLA"
		echo "2 - GAPPS"
		if ! read -t 90 WSYSTYPE; then
    		echo
    		echo "Timeout! No input received."
    		exit 2
		fi


			if [[ "$WSYSTYPE" == "VANILLA" || "$WSYSTYPE" == "1" ]]; then
				
                echo "Installing Waydroid (VANILLA)..."
				yay -S waydroid --noconfirm > /dev/null 2>&1 && sudo systemctl enable --now waydroid-container.service > /dev/null 2>&1 &&
                echo "Downloading system image..."
				sudo waydroid init -f -s VANILLA || { echo; echo "Waydroid installation Failed."; exit 1; }
				echo
				echo "Waydroid (VANILLA) installed successfully."
                echo

			elif [[ "$WSYSTYPE" == "GAPPS" || "$WSYSTYPE" == "2" ]]; then
				
				echo "Installing Waydroid (GAPPS)..."
                yay -S waydroid --noconfirm > /dev/null 2>&1 && sudo systemctl enable --now waydroid-container.service > /dev/null 2>&1 &&
                echo "Downloading system image..."
				sudo waydroid init -f -s GAPPS || { echo; echo "Waydroid installation Failed."; exit 1; }
				echo
				echo "Waydroid (GAPPS) installed successfully."
				echo

			else
				echo "Error: Invalid input."
				exit 2
			fi
}
# Waydroid X11 Installation Function
install_waydroid_x11() {
    		# Check if weston is already installed				
		    if pacman -Q weston > /dev/null 2>&1; then
                echo "Installing Waydroid X11..."
                sleep 1
                {
				sudo cp ../waydroid-x11 /usr/bin/
	            sudo cp ../waydroid-x11.desktop /usr/share/applications/
	            sudo chown root:root /usr/bin/waydroid-x11 /usr/share/applications/waydroid-x11.desktop
	            sudo chmod +x /usr/bin/waydroid-x11
				}
				
				{
				sleep 0.75
				echo "Waydroid X11 installed successfully."
				}

            elif ! pacman -Q weston > /dev/null 2>&1; then
                echo "Installing Weston and Waydroid X11..."
                sleep 1
                {
				sudo cp ../waydroid-x11 /usr/bin/
	            sudo cp ../waydroid-x11.desktop /usr/share/applications/
	            sudo chown root:root /usr/bin/waydroid-x11 /usr/share/applications/waydroid-x11.desktop
	            sudo chmod +x /usr/bin/waydroid-x11
				}
				
                sudo pacman -S weston --noconfirm  > /dev/null 2>&1 &&
				{
				sleep 0.75
				echo "Waydroid X11 installed successfully."
				} ||

                {
				echo "Weston installation failed. Please install it manually: sudo pacman -S weston"
				exit 1
				}
            fi
}
# Waydroid Script Installation Function
install_waydroid_script() {
    if pacman -Q waydroid-script-git > /dev/null 2>&1; then
		echo "Reinstalling Waydroid Script..."
		yay -S waydroid-script-git --noconfirm > /dev/null 2>&1 || { echo; echo "Waydroid script reinstallation failed."; exit 1; }
		
		echo
		echo "Waydroid Script reinstalled successfully."
		echo "You can launch it using: sudo waydroid-extras"
	elif ! pacman -Q waydroid-script-git > /dev/null 2>&1; then
		echo "Installing Waydroid Script..."
		yay -S waydroid-script-git --noconfirm > /dev/null 2>&1 || { echo; echo "Waydroid script installation failed."; exit 1; }
		
		echo
		echo "Waydroid Script installed successfully."
		echo "You can launch it using: sudo waydroid-extras"
	else
        echo "Waydroid Script:"
		echo 'Unknown error!'
		echo "if you encounter any probles,"
		echo "please rerun the script."
		exit 1
	fi
}

# Main options
echo
echo "What would you like to install? (1/2/3/4)"
echo
echo "1 - Waydroid only"
echo "2 - Waydroid X11"
echo "3 - Waydroid Script (and waydroid)"
echo "4 - All of the above"
if ! read -t 90 MAINANS; then
    echo
    echo "Timeout! No input received."
    exit 2
fi

    if [[ "$MAINANS" == "1" ]]; then
        install_waydroid
    elif [[ "$MAINANS" == "2" ]]; then
        install_waydroid_x11
    elif [[ "$MAINANS" == "3" ]]; then
        install_waydroid_script
    elif [[ "$MAINANS" == "4" ]]; then
        echo; echo "Wait for installation..."
        install_waydroid
        install_waydroid_x11
        install_waydroid_script
    elif [[ -z "$MAINANS" || "$MAINANS" != "1" || "$MAINANS" != "2" || "$MAINANS" != "3" || "$MAINANS" != "4" ]]; then
		echo "Error: Invalid input."
		exit 1
	else
		echo "Unknown ERROR!"
		echo "please rerun script."
		exit 1
	fi

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

# Available installation functions:
# install_waydroid
# install_waydroid_x11
# install_waydroid_script

# Check for required packages:
dpkg -s python3 > /dev/null 2>&1 || echo "Warning!: Package 'python3' not found!"
dpkg -s python3-venv > /dev/null 2>&1 || echo "Warning!: Package 'python3-venv' not found!"
dpkg -s git > /dev/null 2>&1 || echo "Warning!: Package 'git' not found!"
dpkg -s curl > /dev/null 2>&1 || echo "Warning!: Package 'curl' not found!"
dpkg -s ca-certificates > /dev/null 2>&1 || echo "Warning!: Package 'ca-certificates' not found!"

# List of already installed components
echo
echo "Installed Components:"
echo

# Check if Waydroid is installed
if [[ -x /usr/bin/waydroid ]]; then
	echo "Waydroid"
fi

# Check if Waydroid Script is installed
if [[ -d ~/waydroid_script && -x ~/waydroid_script/main.py ]]; then
	echo "Waydroid Script"
fi

# Check if Waydroid X11 setup is present
if [[ -x /usr/bin/waydroid-x11 && -f /usr/share/applications/waydroid-x11.desktop ]]; then
	echo "Waydroid X11"
fi

# If none of the above are installed
if [[ ! -x /usr/bin/waydroid-x11 && ! -f /usr/share/applications/waydroid-x11.desktop && ! -d ~/waydroid_script && ! -x /usr/bin/waydroid ]]; then
    echo "Nothing"
fi

# Waydroid Installation Function
install_waydroid() {

		
    	echo "Select Waydroid type: (1/2)"
		echo "1 - VANILLA"
		echo "2 - GAPPS"
		if ! read -t 90 WSYSTYPE; then
    		echo
    		echo "Timeout! No input received."
    		exit 2
		fi

			if [[ "$WSYSTYPE" == "VANILLA" || "$WSYSTYPE" == "1" ]]; then
                echo "Installing Waydroid (VANILLA)..."
				{
				sudo apt-get install curl ca-certificates -y > /dev/null 2>&1
				curl -s https://repo.waydro.id | sudo bash > /dev/null 2>&1
				sudo apt-get update > /dev/null 2>&1
				sudo apt-get install waydroid -y > /dev/null
				} &&
                echo "Downloading system image..."
				sudo waydroid init -f -s VANILLA || { echo; echo "Waydroid installation Failed!"; exit 1; }
				echo
				echo "Waydroid (VANILLA) installed successfully."
                echo

			elif [[ "$WSYSTYPE" == "GAPPS" || "$WSYSTYPE" == "2" ]]; then
				echo "Installing Waydroid (GAPPS)..."
                {
				sudo apt-get install curl ca-certificates -y > /dev/null 2>&1
				curl -s https://repo.waydro.id | sudo bash > /dev/null 2>&1
				sudo apt-get update > /dev/null 2>&1
				sudo apt-get install waydroid -y > /dev/null
				} &&
                echo "Downloading system image..."
				sudo waydroid init -f -s GAPPS || { echo; echo "Waydroid installation Failed!"; exit 1; }
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
		    if [[ -x /usr/bin/weston ]]; then
                echo "Installing Waydroid X11..."
                sleep 1
                {
				sudo cp ../waydroid-x11 /usr/bin/
	            sudo cp ../waydroid-x11.desktop /usr/share/applications/
	            sudo chown root:root /usr/bin/waydroid-x11 /usr/share/applications/waydroid-x11.desktop
	            sudo chmod +x /usr/bin/waydroid-x11
				}
				sudo apt-get update > /dev/null 2>&1
                sudo apt-get install weston -y > /dev/null 2>&1 &&
				{
				sleep 0.75
				echo "Waydroid X11 installed successfully."
				}

            elif [[ ! -x /usr/bin/weston ]]; then
                echo "install Waydroid X11 and Weston..."
                echo "Please wait..."
                sleep 1
                {
				sudo cp ../waydroid-x11 /usr/bin/
	            sudo cp ../waydroid-x11.desktop /usr/share/applications/
	            sudo chown root:root /usr/bin/waydroid-x11 /usr/share/applications/waydroid-x11.desktop
	            sudo chmod +x /usr/bin/waydroid-x11
				}
				sudo apt-get update > /dev/null 2>&1
                sudo apt-get install weston -y > /dev/null 2>&1 &&
				{
				sleep 0.75
				echo "Waydroid X11 installed successfully."
				} ||
                {
				echo "Weston installation failed. Please install it manually: sudo apt install weston"
				exit 1
				}
            fi
}
# Waydroid Script Installation Function
install_waydroid_script() {
	if [[ -d ~/waydroid_script ]]; then
		echo "Reinstalling Waydroid Script..."
		sudo rm -rf ~/waydroid_script
	elif [[ ! -d ~/waydroid_script ]]; then
		echo "Installing Waydroid Script..."
	fi
		git clone https://github.com/casualsnek/waydroid_script.git ~/waydroid_script &&
		python3 -m venv ~/waydroid_script/venv &&
		~/waydroid_script/venv/bin/pip install -r ~/waydroid_script/requirements.txt > /dev/null 2>&1 &&
		{
		echo
		echo "Waydroid Script installed successfully."
		echo "You can launch it using: sudo ~/waydroid_script/venv/bin/python3 ~/waydroid_script/main.py "
		}
}
# Main options
echo
echo "What would you like to install? (1/2/3/4)"
echo
echo "1 - Waydroid"
echo "2 - Waydroid X11"
echo "3 - Waydroid Script"
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
		echo "Unknown ERROR."
		echo "please rerun script."
		exit 1
	fi

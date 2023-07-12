#!/bin/bash
#
# Shell script for installing latest ansible version on compatible os.
# If ansible is present, this script will try to update it to latest version using pip.
#
# Verified on:
### Debian: 10, 11
### Ubuntu: 18.04, 20.04, 22.04

# Exit immediately if a command exits with a non-zero status
set -e

# Check if ansible is installed
if ! command -v ansible >/dev/null; then
        echo "Ansible not found, next step will install ansible dependencies and git"
	
	# Check which package manager your system is using
        if command -v apt >/dev/null; then
                sudo apt-get update -qq
                sudo apt-get install -y -qq git python3 python3-pip python3-dev wget vim 
        else
		# If you are using different package manager, the script exits
                echo "No compatible package manager found! Exiting ..."
                exit 1
        fi
	
	# Check if pip is installed
	# Useful so it won't break ansible installation 
	if command -v pip >/dev/null; then
		# Upgrade pip to the latest version
		sudo -H pip install --upgrade pip 
        
	# Make sure setuptools are installed correctly.
        sudo -H pip install setuptools --upgrade --use-feature=no-binary-enable-wheel-cache
	
	# Install ansible with pip
	sudo -H pip install --upgrade -q ansible 
	exit 0
	fi
fi

# Print on screen current ansible version
echo "Ansible $(ansible --version | head -n1 | cut -c9-15) installed and updated. Enjoy :)"
exit 0

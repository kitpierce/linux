#!/bin/bash

# Using info from: https://www.kevin-custer.com/blog/disabling-snaps-in-ubuntu-20-04/

SNAPPATHS=( "$HOME/snap" "/snap" "/var/snap" "/var/lib/snapd" )
SNAPLIST=()


if [[ ! $(command -v snapd) ]];then
	echo "Binary 'snapd' not currently installed..."
else

	echo "Collecting list of currently installed Snap packages (snap list)"
	for SNAP in $(snap list | grep -Ev '^Name\s+' | awk '{print $1}');do
		if [[ "$SNAP" != "snapd" ]]; then
			SNAPLIST=( "${SNAPLIST[@]}" "$SNAP" );
		fi
	done


	if [ "${#SNAPLIST[@]}" -eq 0 ]; then
		echo "No Snap packages currently installed"
	else
		echo "Currently installed Snap package count: '${#SNAPLIST[@]}'"
		
		echo "Initiating removal of Snap packages..."
		for SNAP in "${SNAPLIST[@]}";do
			echo "Removing Snap object: '$SNAP'"
			sudo snap remove $SNAP || (
				echo "Error removing Snap package: '$SNAP'"
				return 1
			)
		done
	fi

	echo "Looking for mounted Snap directories..."
	for COREMOUNT in $(mount | grep -E '^\/' | grep '/snap/core' | awk '{print $1}'); do
		echo "Unmounting Snap core directory: '$COREMOUNT'"
		sudo umount $COREMOUNT || (
			echo "Error unmounting Snap core directory: '$COREMOUNT'"
			return 1
		)
	done

	echo "Purging Snap daemon (apt autoremove --purge)"
	sudo apt autoremove --purge snapd gnome-software-plugin-snap -y || (
		echo "Error removing 'snapd' or 'gnome-software-plugin-snap' packages"
		return 1
	)

	for TEMPPATH in "${SNAPPATHS[@]}";do
		if [ -d "$TEMPPATH" ]; then
			echo "Removing Snap directory path: '$TEMPPATH'"
			sudo rm -rf $TEMPPATH
		fi
	done

	echo "Snap removal complete - please reboot now..."
fi

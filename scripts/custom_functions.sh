#!/bin/bash

# Elevate permissions via sudo
function elevate_sudo {
    if [ $EUID != 0 ]; then
        sudo "$0" "$@"
        exit $?
    fi
}

function install_ttfonts() {
	updatecache=false
	if [ $# -lt 1 ]; then
		printf "No passed arguments found.\n" && exit 1
	fi
	
	if [ $EUID != 0 ]; then
        	sudo uname -a > /dev/null || exit 1
	fi
    
	fontbase=/usr/share/fonts
	
	while (($#)); do
		# Test if path is a dir or file
		if [ -d $1 ]; then
			printf "\tPath is a directory: '$1'\n"
			dirfonts=$(find $1 | grep -i .ttf$)
			install_ttfonts $dirfonts
		elif [ -f $1 ]; then
			# Test if file is a TTF file
			if [ $(echo $1 | grep -i .ttf) ]; then
				file=$(basename $1)
				# Check if font directory already contains this font
				if [ $(ls $fontbase | grep -i $file) ]; then
					printf "\tFont path '$fontbase' already contains TTF file: '$file'\n"
				else
					printf "\tAdding TTF font file: '$1'\n"
					sudo cp $1 $fontbase
					updatecache=true
				fi
			else
				printf "\tFile is not a ttf font: '$1'\n"
			fi
		fi
		shift
	done

	# Reload font cache	if new fonts were added
	if [ "$updatecache" = true ]; then
		sudo fc-cache -fv
	fi
}

function find_recent_files {
    AGO=10
    FORMAT=minutes

    touch -t $(date -d "-$AGO $FORMAT" "+%Y%m%d%H%M") start

    find ./* -newer start -type f
    
    # find . -newer start \! -newer stop
}

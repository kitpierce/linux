#!/bin/bash
## Info: This script installs and configures 'GRC' - the generic colourizer (https://github.com/garabik/grc)



function get_script_dir () {
     # While $SOURCE is a symlink, resolve it
     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          # If $SOURCE was a relative symlink (so no "/" as prefix, 
		  # need to resolve it relative to the symlink base directory
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
     echo "$DIR"
}

function test_command () {
	if [ -z "$1" ]; then
		printf "No command name supplied\n"
		printf "Usage: '${FUNCNAME[0]} command_to_test'"
		return 1
	else
		CMD_NAME="$1"
		CMD_PATH=$(command -v "${CMD_NAME}")
		#if [ ! $(command -v "$CMD_NAME") ];then
		if [ "${CMD_PATH}" == "" ];then
			printf "[${FUNCNAME[0]}] Command '$CMD_NAME' not resolved\n"
			return 1
		else
			printf "[${FUNCNAME[0]}] Command '${CMD_NAME}' resolved to path: '${CMD_PATH}'\n"
			return 1
		fi
	fi
}

function update_locate {
	printf "[${FUNCNAME[0]}] Updating locatedb database...\n"
	if [ ! $(command -v locate) ];then
		printf "[${FUNCNAME[0]}] Required command 'locate' not found...\n"
		return 1
	else
		printf "[${FUNCNAME[0]}] Invoking updatedb...\n"
		sudo updatedb --prunepaths=/mnt/*
	fi
}

function dot_source {
	for FILE in "$@"; do
		if [[ -f "$FILE" ]];then
			printf "[${FUNCNAME[0]}] Sourcing file: '$FILE'\n"
			source $FILE || (
				printf "[${FUNCNAME[0]}] Error sourcing file: '$FILE'\n" &&
				return 1
			)
		else
			printf "[${FUNCNAME[0]}] No such file: '$FILE'\n"
		fi
	done
}

function backup_file {
	for FILE in "$@"; do
		if [[ -f "$FILE" ]];then
			printf "[${FUNCNAME[0]}] Backing up file: '$FILE'\n"
			TIMESTAMP=$(stat -c %Y $FILE | sed 's#$($FILE)##')
			FILEORIG="$FILE.orig"
			FILETS="$FILE.$TIMESTAMP"
			if [[ ! -f "$FILEORIG" ]];then
				printf "[${FUNCNAME[0]}] Attempting 'orig' backup: '$FILEORIG'\n"
				sudo cp "$FILE" "$FILEORIG" && (
					printf "[${FUNCNAME[0]}] Created 'orig' backup: '$FILEORIG'\n"
					return 0
				) || (
					printf "[${FUNCNAME[0]}] Error creating 'orig' backup: '$FILEORIG'\n" &&
					return 1
				)
			elif [[ ! -f "$FILETS" ]];then
				printf "[${FUNCNAME[0]}] Attempting timestamp backup: '$FILETS'\n"
				sudo cp "$FILE" "$FILETS" && (
					printf "[${FUNCNAME[0]}] Created timestamp backup: '$FILETS'\n"
					return 0
				) || (
					printf "[${FUNCNAME[0]}] Error creating timestamp backup: '$FILETS'\n" &&
					return 1
				)
			else
				printf "[${FUNCNAME[0]}] Timestamp & orig backups exist: '$FILEORIG' '$FILETS'\n"
				return 0
			fi
		else
			printf "[${FUNCNAME[0]}] No such file: '$FILE'\n"
		fi
	done
}

function grc_precheck {
	printf "[${FUNCNAME[0]}] Begin pre-installation checks...\n"
	# Check if grc already installed
	if [ $(command -v grc) ];then
		printf "[${FUNCNAME[0]}] GRC binary already installed: '$(command -v grc)'\n"
		return 0
	# Check for Homebrew environment
	elif [ $(command -v brew) ];then
		printf "[${FUNCNAME[0]}] Homebrew installation detected - install GRC using 'brew install grc'\n"
		return 1
	else
		printf "[${FUNCNAME[0]}] GRC binary is not currently installed"
	fi

	# Test for git command
	if [ ! $(command -v git) ];then
		printf "[${FUNCNAME[0]}] Required program 'git' not installed - quitting...\n"
		return 1
	else
		printf "[${FUNCNAME[0]}] Required program 'git' installed at '$(command -v git)'\n"
	fi

	# Test python version
	PYVER='python3.7'
	if [ $(command -v python3) ];then
		printf "[${FUNCNAME[0]}] Required program 'python3' installed at '$(command -v python3)'\n"
	elif [ $(command -v $PYVER) ]; then
		printf "[${FUNCNAME[0]}] Alternate program '$PYVER' installed at '$(command -v $PYVER)'\n"
		if [[ ! -f "/usr/bin/$PYVER" ]];then
			printf "[${FUNCNAME[0]}] Creating python3 symlink '$(command -v $PYVER)' --> '/usr/bin/python3'\n"
			sudo ln -s "$(command -v $PYVER)" "/usr/bin/python3"
		else
			printf "[${FUNCNAME[0]}] Found existing python3 installation - skipping symbolic link creation\n"
			return 0
		fi
	else
		printf "[${FUNCNAME[0]}] Required program 'python3' (or most recent version) not installed - quitting...\n"
		return 1
	fi 
}

function grc_install {
	URL="https://github.com/garabik/grc.git"
	printf "[${FUNCNAME[0]}] Checking for GRC installation status...\n"
	if [ $(command -v grc) ];then
		printf "[${FUNCNAME[0]}] Binary 'grc' is installed: '$(command -v grc)'\n"
	else
		printf "[${FUNCNAME[0]}] Binary 'grc' not currently installed...\n"
		if [ $(command -v brew) ];then
			printf "[${FUNCNAME[0]}] Installing GRC using Homebrew (brew install grc)\n"
			(brew update >> /dev/null && brew install grc >> /dev/null) || \
				(printf "[${FUNCNAME[0]}] Failed installing GRC with Homebrew!\n" && return 1)
			printf "[${FUNCNAME[0]}] Installed/updated GRC with Homebrew\n"
		else
			printf "[${FUNCNAME[0]}] Installing GRC using Git (git clone $URL)\n"
			# Clone GRC GitHub repo
			if [ ! -d ./grc ];then
				printf "[${FUNCNAME[0]}] Cloning GRC repository from GitHub\n"
				git clone $URL
			fi

			# Run install script from GitHub repo
			printf "[${FUNCNAME[0]}] Running install script from GitHub\n"
			cd ./grc
			sudo ./install.sh || (sudo rm -rf ./grc; return 1)
			cd ..
			sudo rm -rf ./grc

			printf "[${FUNCNAME[0]}] Invoking 'updatedb' to add new GRC files to index...\n"
			sudo updatedb --prunepaths=/mnt/*
		fi
	fi
}

function grc_source {
	printf "[${FUNCNAME[0]}] Updating file list database...\n"
	update_locate || return 1

	printf "[${FUNCNAME[0]}] Begin sourcing GRC's bashrc file...\n"
	GRCCMD=$(command -v grc)
	GRCBASHRC=$(locate grc.bashrc | grep -E -iv '(^/mnt/|/timeshift/|/git/)' | grep -i grc.bashrc$)

	if [[ "$GRCBASHRC" == "" ]];then
		GRCBASHRC="/etc/profile.d/grc.sh"
		printf "[${FUNCNAME[0]}] Locate found no grc config file - using default: '$GRCBASHRC'...\n"
	else
		printf "[${FUNCNAME[0]}] Locate returned grc config file: '$GRCBASHRC'\n"
	fi

	if [ ! $GRCCMD ];then
		printf "[${FUNCNAME[0]}] GRC command not found!\n"
		return 1
	elif [ ! -x $GRCCMD ];then
		printf "[${FUNCNAME[0]}] GRC command '$(echo $GRCCMD)' exists but is not executable\n"
		chmod +x "$GRCCMD" || (
			printf "[${FUNCNAME[0]}] Unable to set executable bit: '$GRCCMD'\n" \
			&& return 1
		)
	else
		printf "[${FUNCNAME[0]}] GRC command '$(echo $GRCCMD)' exists and is executable\n"
	fi

	printf "[${FUNCNAME[0]}] Begin sourcing GRC config: '$GRCBASHRC'\n"
	dot_source "$GRCBASHRC"

	# If not already there, add GRC colorization to ~/.bashrc file
	USERBASHRC="$HOME/.bashrc.grc"
	TESTSTRING="source $GRCBASHRC"
	if [[ ! $(cat $USERBASHRC) =~ "$TESTSTRING" ]]; then
		printf "[${FUNCNAME[0]}] Adding GRC definitions to user's .bashrc file: '$USERBASHRC'\n"
		printf "\n\n# Source GRC colorization file\nif [[ -f "$GRCBASHRC" ]]; then\n\t$TESTSTRING\nfi\n" >> $USERBASHRC
	else
		echo "[${FUNCNAME[0]}] User profile config '$USERBASHRC' already contains reference to GRC config: '$GRCBASHRC'";
	fi

	# Source .bashrc to apply changes
	printf "[${FUNCNAME[0]}] Sourcing user's profile config to load changes: '$USERBASHRC'\n"
	dot_source $USERBASHRC
	printf "[${FUNCNAME[0]}] GRC configuration complete!!\n\n"
}

function update_grc_aliases {
	if [[ "$GRCBASHRC" == "" ]];then
		printf "[${FUNCNAME[0]}] Locate failed to find grc config file: 'grc.bashrc'\n"
		return 1
	elif [[ ! -f "$GRCBASHRC" ]];then
		printf "[${FUNCNAME[0]}] GRC config file is defined but missing: '$GRCBASHRC'\n"
		return 1
	else
		printf "[${FUNCNAME[0]}] Processing GRC config file: '$GRCBASHRC'\n"
		IFS=''
		while read LINE; do
			if [[ "$LINE" =~ "alias colourify" ]];then
				#printf "Skipping colorify alias: '$LINE'\n"
				printf ''
			elif [[ "$LINE" =~ "alias " ]];then
				
				CMD=$(echo "$LINE" | sed 's#.*alias ##' | sed 's#=.*##')
				#echo "Processing alias: '$LINE'"
				#echo "Testing command alias: '$CMD'"
				CPATH=$(which "$CMD")
				if [[ "$CPATH" == "" ]];then
					
					if [[ "$LINE" =~ "#alias" ]];then
						printf "[${FUNCNAME[0]}] Alias already commented out: '$LINE'\n"
					else
						NEWLINE=$(echo $LINE | sed "s/alias/#alias/")
						printf "\tCommented alias: '$NEWLINE'\n"
						sudo sed -i "s/$LINE/$NEWLINE/g" $GRCBASHRC
					fi
				else
					if [[ "$LINE" =~ "#alias" ]];then
						#printf "[${FUNCNAME[0]}] Uncommenting alias: '$LINE'\n"
						NEWLINE=$(echo $LINE | sed "s/(#+)alias/alias/")
						printf "\tUncommenting alias: '$NEWLINE'\n"
						sudo sed -i "s/$LINE/$NEWLINE/g" $GRCBASHRC
					else
						printf "[${FUNCNAME[0]}] Alias already uncommented: '$LINE'\n"
					fi
				fi
			fi
		done < $GRCBASHRC
		unset IFS
	fi
}

function test_grc_environment {
	printf "[${FUNCNAME[0]}] Begin testing GRC environment...\n"
	EXCLUDE="(^/mnt/|/timeshift/|/git/)"
	GRCBIN=$(command -v grc)
	GRCCONFDIR=$(echo "$GRCBIN" | sed "s%/bin/%/share/%g")
	GRCBASHRC=$(locate grc.bashrc | grep -Eiv "$(echo $EXCLUDE)" | grep -Ei 'grc.bashrc$')
}


function grc_alias_all {
	printf "[${FUNCNAME[0]}] Begin adding GRC aliases...\n"
	GRCCONFDIR=$(command -v grc | sed "s%/bin/%/share/%g")
	GRCBASHRC=$(locate grc.bashrc | grep -Eiv '(^/mnt/|/timeshift/|/git/)' | grep -i grc.bashrc$)
	GRCBASHBACKUP=$(echo $GRCBASHRC | sed "s%bashrc%bashrc.orig%g")
	GRCTMPBASHRC=$(echo $GRCBASHRC | sed "s%bashrc%bashrc.temp%g")

	if [ ! -d $GRCCONFDIR ];then 
		printf "[${FUNCNAME[0]}] GRC configuration file directory not found: '$GRCCONFDIR'\n"
		return 1
	else
		printf "[${FUNCNAME[0]}] Using GRC configuration file path: '$GRCCONFDIR'\n"
	fi

	if [ -f $GRCBASHRC ];then
		if [ -f $GRCBASHBACKUP ];then
			printf "[${FUNCNAME[0]}] GRC bashrc file backup exists: '$GRCBASHBACKUP'\n"
		else
			printf "[${FUNCNAME[0]}] Creating GRC bashrc backup: '$GRCBASHBACKUP'\n"
			sudo cp "$GRCBASHRC" "$GRCBASHBACKUP" || (
				printf "[${FUNCNAME[0]}] Error creating GRC bashrc backup!\n" && \
				return 1
			)
		fi
	fi

	# Create temporary config file
	printf "[${FUNCNAME[0]}] Creating temporary bashrc file: '$GRCTMPBASHRC'\n"
	if [ -f $GRCTMPBASHRC ]; then
		rm $GRCTMPBASHRC || (
			printf "[${FUNCNAME[0]}] Error removing existing temporary bashrc: '$GRCTMPBASHRC'" && \
			return 1
		)
	fi
	sudo touch $GRCTMPBASHRC || (
		printf "[${FUNCNAME[0]}] Error creating temporary bashrc file: '$GRCTMPBASHRC'" && \
		return 1
	)

	printf "[${FUNCNAME[0]}] Adding all GRC aliases to temporary config file: '$GRCTMPBASHRC'\n"
	# Create a temporary bashrc file and add beginning definitions
	echo -e 'GRC="$(which grc)"\nif [ "$TERM" != dumb ] && [ -n "$GRC" ]; then\n\talias colourify="$GRC -es --colour=auto"' | \
		sudo tee "$GRCTMPBASHRC" > /dev/null

	# Add an alias for all GRC config files in configuration directory to temporary bashrc
	OIFS="$IFS"
	IFS=$'\n'
	for file in $(ls $GRCCONFDIR | sed "s%conf.%%g")
	do
		if [ $(command -v $file) ];then
			printf "[${FUNCNAME[0]}] \tAdding alias for command: '$file'\n"
			ALIAS_STRING="\talias $file='colourify $file'\n"
		else
			printf "[${FUNCNAME[0]}] \tAdding commented alias for command: '$file'\n"
			ALIAS_STRING="\t#alias $file='colourify $file'\n"
		fi
			printf "[${FUNCNAME[0]}] $ALIAS_STRING" | sudo tee --append "$GRCTMPBASHRC" > /dev/null
	done
	IFS="$OIFS"

	# Add closing 'fi' statement to temporary bashrc
	printf 'fi\n' | sudo tee --append "$GRCTMPBASHRC" > /dev/null

	# Replace stock config with updated temporary config
	sudo mv $GRCTMPBASHRC $GRCBASHRC && \
		(
			printf "[${FUNCNAME[0]}] Deployed updated GRC bashrc: '$GRCBASHRC'\n" && \
			return 0
		) || (
			printf "[${FUNCNAME[0]}] Error deploying GRC bashrc with updated aliases!\n" && \
			return 1
		)
}



ORIGDIR=$(pwd)
SCRIPTDIR=$(get_script_dir)

grc_precheck && \
	grc_install && \
	grc_alias_all && \
	grc_source

if [ "$(pwd)" != "$ORIGDIR" ];then
	printf "[${FUNCNAME[0]}] Changing directory '$(pwd)' --> '$ORIGDIR'\n"
	cd $ORIGDIR
fi

#!/bin/bash
## Info: This script installs and configures 'GRC' - the generic colourizer (https://github.com/garabik/grc)

HUE_BLACK=$(tput setaf 0)
HUE_RED=$(tput setaf 1)
HUE_GREEN=$(tput setaf 2)
HUE_YELLOW=$(tput setaf 3)
HUE_LIME=$(tput setaf 190)
HUE_POWDER=$(tput setaf 153)
HUE_BLUE=$(tput setaf 4)
HUE_MAGENTA=$(tput setaf 5)
HUE_CYAN=$(tput setaf 6)
HUE_WHITE=$(tput setaf 7)
BOLD_BLACK=$(tput bold; tput setaf 0)
BOLD_RED=$(tput bold; tput setaf 1)
BOLD_GREEN=$(tput bold; tput setaf 2)
BOLD_YELLOW=$(tput bold; tput setaf 3)
BOLD_LIME=$(tput bold; tput setaf 190)
BOLD_POWDER=$(tput bold; tput setaf 153)
BOLD_BLUE=$(tput bold; tput setaf 4)
BOLD_MAGENTA=$(tput bold; tput setaf 5)
BOLD_CYAN=$(tput bold; tput setaf 6)
BOLD_WHITE=$(tput bold; tput setaf 7)
BOLD=$(tput bold)
CLEAR=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

SHOW_CALL=$(printf "${BOLD_LIME}[$(basename "$0")]${CLEAR} ")


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
	local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")
	if [ -z "$1" ]; then
		printf "${SHOW_CALL}No command name supplied\n"
		printf "Usage: '${FUNCNAME[0]} command_to_test'"
		return 1
	else
		CMD_NAME="$1"
		CMD_PATH=$(command -v "${CMD_NAME}")
		#if [ ! $(command -v "$CMD_NAME") ];then
		if [ "${CMD_PATH}" == "" ];then
			printf "${SHOW_CALL}Command '$CMD_NAME' not resolved\n"
			return 1
		else
			printf "${SHOW_CALL}Command '${CMD_NAME}' resolved to path: '${CMD_PATH}'\n"
			return 1
		fi
	fi
}

function update_locate {
	local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")
	local FAILURE=""
	if [[ $(command -v locate) ]];then
		printf "${SHOW_CALL}Found required command: 'locate'\n"
	elif [[ ! $(command -v mlocate) ]];then
		printf "${SHOW_CALL}Found required command: 'mlocate'\n"
	else
		printf "${SHOW_CALL}Required command 'locate' or 'mlocate' not found...\n"
		local FAILURE="command 'locate/mlocate' not found"
	fi

	[[ "$FAILURE" == "" ]] && (
		printf "${SHOW_CALL}Updating locatedb database...\n"
		sudo updatedb --prunepaths=/mnt/* 2>&1 | grep -vi 'Permission denied' || local FAILURE="sudo updatedb"
	)
	
	[[ "$FAILURE" == "" ]] && (
		#printf "${SHOW_CALL}Finished Homebrew install for GRC\n"
		printf "${SHOW_CALL}Finished updatedb...\n"
		return 0
	) || (
		printf "${SHOW_CALL}Failed command: '$FAILURE'"
		return 1
	)
}

function dot_source {
	local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")
	for FILE in "$@"; do
		if [[ -f "$FILE" ]];then
			printf "${SHOW_CALL}Sourcing file: '$FILE'\n"
			source $FILE || (
				printf "${SHOW_CALL}Error sourcing file: '$FILE'\n" &&
				return 1
			)
		else
			printf "${SHOW_CALL}No such file: '$FILE'\n"
		fi
	done
}

function backup_file {
	local BOLD_BLACK=$(tput bold; tput setaf 0)
	local BOLD_RED=$(tput bold; tput setaf 1)
	local BOLD_GREEN=$(tput bold; tput setaf 2)
	local BOLD_YELLOW=$(tput bold; tput setaf 3)
	local BOLD_CYAN=$(tput bold; tput setaf 6)
	local CLEAR=$(tput sgr0)


	local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")
	for FILE in "$@"; do
		if [[ -f "$FILE" ]];then
			printf "${SHOW_CALL}Backing up file: '$FILE'\n"
			TIMESTAMP=$(stat -c %Y $FILE | sed 's#$($FILE)##')
			FILEORIG="$FILE.orig"
			FILETS="$FILE.$TIMESTAMP"
			if [[ ! -f "$FILEORIG" ]];then
				printf "${SHOW_CALL}Attempting 'orig' backup: ${BOLD_CYAN}'$FILEORIG'${CLEAR}\n"
				sudo cp "$FILE" "$FILEORIG" && (
					printf "${SHOW_CALL}Created 'orig' backup: ${BOLD_GREEN}'$FILEORIG'${CLEAR}\n"
					return 0
				) || (
					printf "${SHOW_CALL}Error creating 'orig' backup: ${BOLD_RED}'$FILEORIG'${CLEAR}\n" &&
					return 1
				)
			elif [[ ! -f "$FILETS" ]];then
				printf "${SHOW_CALL}Attempting timestamp backup: ${BOLD_CYAN}'$FILETS'${CLEAR}\n"
				sudo cp "$FILE" "$FILETS" && (
					printf "${SHOW_CALL}Created timestamp backup: ${BOLD_GREEN}'$FILETS'${CLEAR}\n"
					return 0
				) || (
					printf "${SHOW_CALL}Error creating timestamp backup: ${BOLD_RED}'$FILETS'${CLEAR}\n" &&
					return 1
				)
			else
				printf "${SHOW_CALL}Timestamp & orig backups exist: ${BOLD_GREEN}'$FILEORIG' '$FILETS'${CLEAR}\n"
				return 0
			fi
		else
			printf "${SHOW_CALL}No such file: ${BOLD_YELLOW}'$FILE'${CLEAR}\n"
			return 0
		fi
	done
}

function grc_precheck {
	local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")
	printf "${SHOW_CALL}Begin pre-installation checks...\n"
	# Check if grc already installed
	if [ $(command -v grc) ];then
		printf "${SHOW_CALL}GRC binary already installed: '$(command -v grc)'\n"
		return 0
	# Check for Homebrew environment
	elif [ $(command -v brew) ];then
		printf "${SHOW_CALL}Homebrew installation detected - install GRC using 'brew install grc'\n"
		return 1
	else
		printf "${SHOW_CALL}GRC binary is not currently installed\n"
	fi

	# Test for git command
	if [ ! $(command -v git) ];then
		printf "${SHOW_CALL}Required program 'git' not installed - quitting...\n"
		return 1
	else
		printf "${SHOW_CALL}Required program 'git' installed at '$(command -v git)'\n"
	fi

	# Test python version
	PYVER='python3.7'
	if [ $(command -v python3) ];then
		printf "${SHOW_CALL}Required program 'python3' installed at '$(command -v python3)'\n"
	elif [ $(command -v $PYVER) ]; then
		printf "${SHOW_CALL}Alternate program '$PYVER' installed at '$(command -v $PYVER)'\n"
		if [[ ! -f "/usr/bin/$PYVER" ]];then
			printf "${SHOW_CALL}Creating python3 symlink '$(command -v $PYVER)' --> '/usr/bin/python3'\n"
			sudo ln -s "$(command -v $PYVER)" "/usr/bin/python3"
		else
			printf "${SHOW_CALL}Found existing python3 installation - skipping symbolic link creation\n"
			return 0
		fi
	else
		printf "${SHOW_CALL}Required program 'python3' (or most recent version) not installed - quitting...\n"
		return 1
	fi 
}

function grc_install {
	local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")
	URL="https://github.com/garabik/grc.git"

	local FAILURE=""
	printf "${SHOW_CALL}Checking for GRC installation status...\n"
	if [ $(command -v grc) ];then
		printf "${SHOW_CALL}Binary 'grc' is installed: '$(command -v grc)'\n"
	else
		printf "${SHOW_CALL}Binary 'grc' not currently installed...\n"
		if [[ $(command -v brew) ]];then
			printf "${SHOW_CALL}Installing GRC using Homebrew (brew install grc)\n"

			printf "${SHOW_CALL}Updating Homebrew formulae (brew update)\n"
			brew update >> /dev/null || local FAILURE="brew update"
			
			[[ "$FAILURE" == "" ]] && (
				printf "${SHOW_CALL}Invoking Homebrew installation (brew install grc)\n"
				brew install grc >> /dev/null || local FAILURE="brew install grc"
			)
			
			[[ "$FAILURE" == "" ]] && (
				printf "${SHOW_CALL}Finished Homebrew install for GRC\n"
			) || (
				printf "${SHOW_CALL}Failed installing GRC with Homebrew\n" && 
				printf "${SHOW_CALL}Failed step: '$FAILURE'\n" && 
				return 1
			)
		else
			printf "${SHOW_CALL}Installing GRC using Git (git clone $URL)\n"
			# Clone GRC GitHub repo
			if [ ! -d ./grc ];then
				printf "${SHOW_CALL}Cloning GRC repository from GitHub\n"
				git clone $URL
			else
				printf "${SHOW_CALL}Updating cloned GRC repository in path: '$(readlink -f ./grc)'\n"
				cd ./grc
				git pull 
				cd ..
			fi

			# Run install script from GitHub repo
			printf "${SHOW_CALL}Running install script from GitHub\n"
			local INSTALL_SCRIPT=$(readlink -f ./grc/install.sh)
			local REPO_DIR=$(readlink -f ./grc)
			printf "${SHOW_CALL}Invoking script: '$INSTALL_SCRIPT'\n"
			
			
			sudo "$INSTALL_SCRIPT" && (
				printf "${SHOW_CALL}Finished execution of script: ${BOLD_GREEN}'$INSTALL_SCRIPT'${CLEAR}\n";
				
			) || (
				printf "${SHOW_CALL}Error running script: ${BOLD_RED}'$INSTALL_SCRIPT'${CLEAR}\n";
				local FAILURE="script '$INSTALL_SCRIPT'"
				return 1
			)

			[[ "$FAILURE" == "" ]] && (
				printf "${SHOW_CALL}Removing local cloned Git directory: '$REPO_DIR'\n"
				sudo rm -rfv "$REPO_DIR" || local FAILURE="rm -rfv '$REPO_DIR'"
			)

			[[ "$FAILURE" == "" ]] && (
				printf "${SHOW_CALL}Invoking 'updatedb' to add new GRC files to index...\n"
				sudo updatedb --prunepaths=/mnt/* || local FAILURE="sudo updatedb"
			)

			
			[[ "$FAILURE" == "" ]] && (
				printf "${SHOW_CALL}Finished GRC install from Git repo script\n"
			) || (
				printf "${SHOW_CALL}Failed GRC install from Git repo script\n" && 
				printf "${SHOW_CALL}Failed step: '$FAILURE'\n" && 
				return 1
			)
		fi
	fi
}

function grc_source {
	local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")
	printf "${SHOW_CALL}Updating file list database...\n"
	update_locate || return 1

	printf "${SHOW_CALL}Begin sourcing GRC's bashrc file...\n"
	GRCCMD=$(command -v grc)

	if [ ! $GRCCMD ];then
		printf "${SHOW_CALL}GRC command not found!\n"
		return 1
	elif [ ! -x $GRCCMD ];then
		printf "${SHOW_CALL}GRC command ${BOLD_YELLOW}'${GRCCMD}'${CLEAR} exists but is not executable\n"
		chmod +x "$GRCCMD" || (
			printf "${SHOW_CALL}Unable to set executable bit: ${BOLD_RED}'$GRCCMD'${CLEAR}\n" \
			&& return 1
		)
	else
		printf "${SHOW_CALL}GRC command ${BOLD_GREEN}'${GRCCMD}'${CLEAR} exists and is executable\n"
	fi

	GRCBASHRC=$(locate grc.bashrc | grep -E -iv '(^/mnt/|/timeshift/|/git/)' | grep -i grc.bashrc$)
	if [[ "$GRCBASHRC" == "" ]];then
		GRCBASHRC="/etc/profile.d/grc.sh"
		printf "${SHOW_CALL}Locate found no grc config file - using default: ${BOLD_YELLOW}'$GRCBASHRC'${CLEAR}\n"
		if [[ ! -f "$GRCBASHRC" ]];then
			printf "${SHOW_CALL}Creating user-specific GRC bashrc file: ${BOLD_YELLOW}'$GRCBASHRC'${CLEAR}\n"
			touch "$GRCBASHRC"
		else
			printf "${SHOW_CALL}Found existing user-specific GRC bashrc file: '$GRCBASHRC'\n"
		fi
	else
		printf "${SHOW_CALL}Locate returned grc config file: '$GRCBASHRC'\n"
	fi

	printf "${SHOW_CALL}Begin sourcing GRC config: '$GRCBASHRC'\n"
	dot_source "$GRCBASHRC"

	# If not already there, add GRC colorization to ~/.bashrc file
	USERBASHRC="$HOME/.bashrc.grc"
	TESTSTRING="source $GRCBASHRC"
	if [[ ! $(cat $USERBASHRC) =~ "$TESTSTRING" ]]; then
		printf "${SHOW_CALL}Adding GRC definitions to user's .bashrc file: ${BOLD_CYAN}'$USERBASHRC'${CLEAR}\n"
		printf "\n\n# Source GRC colorization file\nif [[ -f "$GRCBASHRC" ]]; then\n\t$TESTSTRING\nfi\n" >> $USERBASHRC
	else
		echo "${SHOW_CALL}User profile already contains reference to GRC: ${BOLD_GREEN}'$GRCBASHRC'${CLEAR}";
	fi

	# Source .bashrc to apply changes
	printf "${SHOW_CALL}Sourcing user's profile config to load changes: ${BOLD_GREEN}'$USERBASHRC'${CLEAR}\n"
	dot_source $USERBASHRC
	printf "${SHOW_CALL}GRC configuration complete!!\n\n"
}

function update_grc_aliases {
	local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")
	if [[ "$GRCBASHRC" == "" ]];then
		printf "${SHOW_CALL}Locate failed to find grc config file: 'grc.bashrc'\n"
		return 1
	elif [[ ! -f "$GRCBASHRC" ]];then
		printf "${SHOW_CALL}GRC config file is defined but missing: '$GRCBASHRC'\n"
		return 1
	else
		printf "${SHOW_CALL}Processing GRC config file: '$GRCBASHRC'\n"
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
						printf "${SHOW_CALL}Alias already commented out: '$LINE'\n"
					else
						NEWLINE=$(echo $LINE | sed "s/alias/#alias/")
						printf "\tCommented alias: '$NEWLINE'\n"
						sudo sed -i "s/$LINE/$NEWLINE/g" $GRCBASHRC
					fi
				else
					if [[ "$LINE" =~ "#alias" ]];then
						#printf "${SHOW_CALL}Uncommenting alias: '$LINE'\n"
						NEWLINE=$(echo $LINE | sed "s/(#+)alias/alias/")
						printf "\tUncommenting alias: '$NEWLINE'\n"
						sudo sed -i "s/$LINE/$NEWLINE/g" $GRCBASHRC
					else
						printf "${SHOW_CALL}Alias already uncommented: '$LINE'\n"
					fi
				fi
			fi
		done < $GRCBASHRC
		unset IFS
	fi
}

function test_grc_environment {
	local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")
	printf "${SHOW_CALL}${BOLD_MAGENTA}Begin testing GRC environment...${CLEAR}\n"
	EXCLUDE="(^/mnt/|/timeshift/|/git/)"
	GRCBIN=$(command -v grc)
	#GRCCONFDIR=$(echo "$GRCBIN" | sed "s%/bin/%/share/%g")
	GRCBASHRC=$(locate grc.bashrc | grep -Eiv "$(echo $EXCLUDE)" | grep -Ei 'grc.bashrc$')
}

function grc_alias_all {
	local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")

	local FAILURE=""
	printf "${SHOW_CALL}${BOLD_MAGENTA}Begin adding GRC aliases...${CLEAR}\n"
	
	printf "${SHOW_CALL}Resolving 'grc' binary path ${BOLD_CYAN}(command -v grc)${CLEAR}\n"
	local GRC_BINARY=$(command -v grc)

	# Verify that binary path varible is defined
	[[ -z "$GRC_BINARY" ]] && (
		printf "${SHOW_CALL}Null value for GRC binary: ${BOLD_YELLOW}(command -v grc)${CLEAR}\n"
		local FAILURE="command -v grc"
	) || (
		printf "${SHOW_CALL}Resolved 'grc' binary path: ${BOLD_CYAN}'$GRC_BINARY'${CLEAR}\n"
	)

	[[ "$FAILURE" == "" ]] && (
		printf "${SHOW_CALL}Updating 'locate/mlocate' database\n"
		update_locate || local FAILURE="function 'update_locate'"
	)

	[[ "$FAILURE" == "" ]] && (
		printf "${SHOW_CALL}Resolving Bash config for GRC ${BOLD_CYAN}(locate grc)${CLEAR}\n"
		GRCBASHRC=$(locate grc | grep -Eiv '(^/mnt/|/timeshift/|/git/)' | grep -v $(readlink -f ~) | grep -Ei '(bashrc\.grc|grc\.sh)$')
		if [[ -z "$GRCBASHRC" ]];then 
			GRCBASHRC="~/.bashrc.grc"
			printf "${SHOW_CALL}No Bash config found - using default ${BOLD_CYAN}'$GRCBASHRC'${CLEAR}\n"
		elif [[ -f "$GRCBASHRC" ]];then 
			printf "${SHOW_CALL}Found Bash config file: ${BOLD_CYAN}'$GRCBASHRC'${CLEAR}\n"
		else
			printf "${SHOW_CALL}Locate found Bash config, but file does not exist: ${BOLD_RED}'$GRCBASHRC'${CLEAR}\n"
		fi
	)

	# Create backup of config file
	if [[ "$FAILURE" == "" ]];then 
		if [[ -f "$GRCBASHRC" ]];then
			printf "${SHOW_CALL}Backing up GRC config file: ${BOLD_CYAN}'$GRCBASHRC'${CLEAR}\n"
			backup_file $GRCBASHRC || local FAILURE="failed backup for file '$GRCBASHRC'"
		fi
	fi

	# Set temporary config file name & remove existing temp file if needed
	if [[ "$FAILURE" == "" ]];then 
		GRCTMPBASHRC=$(echo "$GRCBASHRC" | sed -E "s%$%.temp%g")
		printf "${SHOW_CALL}Using temporary config file name: ${BOLD_CYAN}'$GRCTMPBASHRC'${CLEAR}\n"
		if [ -f "$GRCTMPBASHRC" ]; then
			printf "${SHOW_CALL}Removing existing temporary bashrc file: ${BOLD_CYAN}'$GRCTMPBASHRC'${CLEAR}\n"
			rm -v "$GRCTMPBASHRC" || local FAILURE="error removing temporary Bash config '$GRCTMPBASHRC'"
		fi
	fi

	# Add header for alias definitions to temporary config file
	if [[ "$FAILURE" == "" ]];then 
		printf "${SHOW_CALL}Adding header information to temporary config file: ${BOLD_CYAN}'$GRCTMPBASHRC'${CLEAR}\n"
	
		echo -e 'GRC="$(which grc)"\nif [ "$TERM" != dumb ] && [ -n "$GRC" ]; then\n\talias colourify="$GRC -es --colour=auto"' | \
			sudo tee "$GRCTMPBASHRC" > /dev/null || local FAILURE="error adding header to Bash config '$GRCTMPBASHRC'"
	fi

	# Add an alias for all GRC config files in configuration directory to temporary config
	if [[ "$FAILURE" == "" ]];then 
		printf "${SHOW_CALL}Adding all GRC aliases to temporary config file: ${BOLD_CYAN}'$GRCTMPBASHRC'${CLEAR}\n"
		OIFS="$IFS"
		IFS=$'\n'
		for LOCATE_ITEM in $(locate */grc/conf*); do
		#for file in $(ls $GRCCONFDIR | sed "s%conf.%%g");do
			local CONF_BASE=$(basename "$LOCATE_ITEM")
			local CONF_NAME=$(echo "$CONF_BASE" | sed "s%conf.%%g")
			if [ $(command -v "$CONF_NAME") ];then
				printf "${SHOW_CALL}\tAdding alias for command: ${BOLD_GREEN}'$CONF_NAME'${CLEAR}\n"
				local ALIAS_STRING="\talias $CONF_NAME='colourify $CONF_NAME'\n"
			else
				printf "${SHOW_CALL}\tAdding commented alias:   ${BOLD_CYAN}'$CONF_NAME'${CLEAR}\n"
				local ALIAS_STRING="\t#alias $CONF_NAME='colourify $CONF_NAME'\n"
			fi
				printf "$ALIAS_STRING" | sudo tee --append "$GRCTMPBASHRC" > /dev/null
		done
		IFS="$OIFS"

		# Add closing 'fi' statement to temporary bashrc
		printf "${SHOW_CALL}Adding ending line wrap to temporary config file: ${BOLD_CYAN}'$GRCTMPBASHRC'${CLEAR}\n"
		printf 'fi\n' | sudo tee --append "$GRCTMPBASHRC" > /dev/null
	fi

	# Replace stock config with updated temporary config
	if [[ "$FAILURE" == "" ]];then 
		printf "${SHOW_CALL}Moving temporary config to live path: ${BOLD_CYAN}'$GRCBASHRC'${CLEAR}\n"
		sudo mv -v "$GRCTMPBASHRC" "$GRCBASHRC" || local FAILURE="error moving file '$GRCTMPBASHRC' -> '$GRCBASHRC'"
	fi


	if [[ "$FAILURE" == "" ]];then 
		printf "${SHOW_CALL}Deployed updated GRC bashrc: ${BOLD_GREEN}'$GRCBASHRC'${CLEAR}\n" 
	else 
		printf "${SHOW_CALL}Failed GRC alias update: ${BOLD_RED}${FAILURE}${CLEAR}\n"
	fi
}

PROCEED='true'

ORIGDIR=$(pwd)
SCRIPTDIR=$(get_script_dir)
grc_precheck || PROCEED='false'
[[ "$PROCEED" == "true" ]] && grc_install || PROCEED='false'
[[ "$PROCEED" == "true" ]] && grc_alias_all || PROCEED='false'
[[ "$PROCEED" == "true" ]] && grc_source || PROCEED='false'

if [ "$(pwd)" != "$ORIGDIR" ];then
	printf "${SHOW_CALL}Changing directory '$(pwd)' --> '$ORIGDIR'\n"
	cd $ORIGDIR
fi

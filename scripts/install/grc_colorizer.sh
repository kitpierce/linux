#!/bin/bash
## Info: This script installs and configures 'GRC' - the generic colourizer (https://github.com/garabik/grc)

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"
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

ORIGDIR=$(pwd)
SCRIPTDIR=$(get_script_dir)

function grc_precheck {
	printf "Begin pre-installation checks...\n"
	# Check if grc already installed
	if [ $(command -v grc) ];then
		printf "GRC already installed at '$(command -v grc)'\n"
		return 0
	fi

	# Check for Homebrew environment
	if [ $(command -v brew) ];then
		printf "Homebrew installation detected - install GRC using 'brew install grc'\n"
		return 1
	fi

	# Test for git command
	if [ ! $(command -v git) ];then
		printf "Required program 'git' not installed - quitting...\n"
		return 1
	else
		printf "Required program 'git' installed at '$(command -v git)'\n"
	fi

	# Test python version
	if [ $(command -v python3) ];then
		printf "Required program 'python3' installed at '$(command -v python3)'\n"
	elif [ $(command -v python3.6) ]; then
		printf "Alternate program 'python3.6' installed at '$(command -v python3)'\n"
		if [ ! -f /usr/bin/python3.6 ];then
			printf "No existing python3 installation - creating symbolic link\n"
			printf "Creating symlink '/usr/bin/python3.6' --> '/usr/bin/python3'\n"
			sudo ln -s /usr/bin/python3.6 /usr/bin/python3
		else
			printf "Found existing python3 installation - skipping symbolic link creation\n"
			return 0
		fi
	else
		printf "Required program 'python3' (or most recent version) not installed - quitting...\n"
		return 1
	fi 
}

function grc_install {
	printf "Begin installing GRC binary & configs...\n"
	if [ $(command -v grc) ];then
		printf "Binary 'grc' is installed: '$(command -v grc)'\n"
	elif [ $(command -v brew) ];then
		(brew update >> /dev/null && brew install grc >> /dev/null) || \
			(printf "Failed installing GRC with Homebrew!\n" && return 1)
		printf "Installed/updated GRC with Homebrew\n"
	else
		# Clone GRC GitHub repo
		if [ ! -d ./grc ];then
			printf "Cloning GRC repository from GitHub\n"
			git clone https://github.com/garabik/grc.git
		fi

		# Run install script from GitHub repo
		printf "Running install script from GitHub\n"
		cd ./grc
		sudo ./install.sh || (sudo rm -rf ./grc; return 1)
		cd ..
		sudo rm -rf ./grc

		printf "Invoking 'updatedb' to add new GRC files to index...\n"
		sudo updatedb --prunepaths=/mnt/*
	fi
}

function grc_source {
	printf "Begin sourcing GRC's bashrc file...\n"
	GRCCMD=$(command -v grc)
	GRCBASHRC=$(locate grc.bashrc | grep -E -v '(^/mnt/|/timeshift/)' | grep -i grc.bashrc$)
	if [ ! $GRCCMD ];then
		printf "GRC command not found!\n"
		return 1
	elif [ ! -x $GRCCMD ];then
		printf "GRC command '$(echo $GRCCMD)' exists but is not executable\n"
		chmod +x $GRCCMD || (
			printf "Unable to set executable bit: '$GRCCMD'\n" \
			&& return 1
		)
	fi

	if [[ -f $GRCBASHRC ]];then 
		printf "Sourcing GRC bashrc config: '$GRCBASHRC'\n"
		source $GRCBASHRC || (
			printf "Error sourcing GRC bashrc: '$GRCBASHRC'\n" \
			&& return 1
		)
	else
		printf "Cannot source GRC bashrc file: '$GRCBASHRC'\n" \
		&& return 1
	fi

	# If not already there, add GRC colorization to ~/.bashrc file
	USERBASHRC="$HOME/.bashrc"
	TESTSTRING="source $GRCBASHRC"
	if [[ ! `cat $USERBASHRC` =~ "$TESTSTRING" ]]; then
		printf "Adding GRC definitions to user's .bashrc file: '$USERBASHRC'\n"
		printf "\n\n# Source GRC colorization file\nif [ -f $GRCBASHRC ]; then\n\t$TESTSTRING\nfi\n" >> $USERBASHRC
	else
		echo "User bashrc already contains reference to GRC bashrc: '$GRCBASHRC'";
	fi

	# Source .bashrc to apply changes
	printf "Sourcing user's .bashrc to load changes\n"
	[[ -f $USERBASHRC ]] && source $USERBASHRC
	printf "GRC configuration complete!!\n\n"
}

function grc_alias_all {
	printf "Begin adding GRC aliases...\n"
	GRCCONFDIR=$(command -v grc | sed "s%/bin/%/share/%g")
	GRCBASHRC=$(locate grc.bashrc | grep -E -v '(^/mnt/|/timeshift/)' | grep -i grc.bashrc$)
	GRCBASHBACKUP=$(echo $GRCBASHRC | sed "s%bashrc%bashrc.orig%g")
	GRCTMPBASHRC=$(echo $GRCBASHRC | sed "s%bashrc%bashrc.temp%g")

	if [ ! -d $GRCCONFDIR ];then 
		printf "GRC configuration file directory not found: '$GRCCONFDIR'\n"
		return 1
	else
		printf "Using GRC configuration file path: '$GRCCONFDIR'\n"
	fi

	if [ -f $GRCBASHRC ];then
		if [ -f $GRCBASHBACKUP ];then
			printf "GRC bashrc file backup exists: '$GRCBASHBACKUP'\n"
		else
			printf "Creating GRC bashrc backup: '$GRCBASHBACKUP'\n"
			sudo cp $GRCBASHRC $GRCBASHBACKUP || (
				printf "Error creating GRC bashrc backup!\n" && \
				return 1
			)
		fi
	fi

	# Create temporary config file
	printf "Creating temporary bashrc file: '$GRCTMPBASHRC'\n"
	if [ -f $GRCTMPBASHRC ]; then
		rm $GRCTMPBASHRC || (
			printf "Error removing existing temporary bashrc: '$GRCTMPBASHRC'" && \
			return 1
		)
	fi
	sudo touch $GRCTMPBASHRC || (
		printf "Error creating temporary bashrc file: '$GRCTMPBASHRC'" && \
		return 1
	)

	printf "Adding all GRC aliases to temporary config file: '$GRCTMPBASHRC'\n"
	# Create a temporary bashrc file and add beginning definitions
	echo -e 'GRC="$(which grc)"\nif [ "$TERM" != dumb ] && [ -n "$GRC" ]; then\n\talias colourify="$GRC -es --colour=auto"' | \
		sudo tee "$GRCTMPBASHRC" > /dev/null

	# Add an alias for all GRC config files in configuration directory to temporary bashrc
	OIFS="$IFS"
	IFS=$'\n'
	for file in $(ls $GRCCONFDIR | sed "s%conf.%%g")
	do
		if [ $(command -v $file) ];then
			printf "\tAdding alias for command: '$file'\n"
			ALIAS_STRING="\talias $file='colourify $file'\n"
		else
			printf "\tAdding commented alias for command: '$file'\n"
			ALIAS_STRING="\t#alias $file='colourify $file'\n"
		fi
			printf "$ALIAS_STRING" | sudo tee --append "$GRCTMPBASHRC" > /dev/null
	done
	IFS="$OIFS"

	# Add closing 'fi' statement to temporary bashrc
	printf 'fi\n' | sudo tee --append "$GRCTMPBASHRC" > /dev/null

	# Replace stock config with updated temporary config
	sudo mv $GRCTMPBASHRC $GRCBASHRC && \
		(
			printf "Deployed updated GRC bashrc: '$GRCBASHRC'\n" && \
			return 0
		) || (
			printf "Error deploying GRC bashrc with updated aliases!\n" && \
			return 1
		)
}

grc_precheck && \
grc_install && \
grc_alias_all && \
grc_source

if [ "$(pwd)" != "$ORIGDIR" ];then
	printf "Changing directory '$(pwd)' --> '$ORIGDIR'\n"
	cd $ORIGDIR
fi

ORIGDIR=$(pwd)
THEMEBASE="$(echo $HOME)/Git/Themes"

## Set simple TPUT text formatting options
## USAGE: echo "this is ${bold}bold${clean}, this is ${hilite}highlighted${clean}, and this is neither"
bold=$(tput bold; tput setab 0; tput setaf 1)
hilite=$(tput bold; tput setab 0; tput setaf 6)
clean=$(tput sgr0)

## Pre-seed sudo permissions (needed to install themes for all users)
sudo whoami >> /dev/null || break

## Declare arrays of theme's Git URLs to download from
declare -a GTKTHEMES=('https://github.com/adapta-project/adapta-gtk-theme')
declare -a CURSORTHEMES=('https://github.com/KaizIqbal/Bibata_Cursor.git'
	'https://github.com/KaizIqbal/Google_Cursor.git'
)
declare -a TERMINALTHEMES=('https://github.com/Mayccoll/Gogh.git' 
	'https://github.com/mbadolato/iTerm2-Color-Schemes.git'
)
declare -a ICONTHEMES=( 'https://github.com/daniruiz/flat-remix.git'
	'https://github.com/USBA/Cupertino-macOS-iCons.git'
	'https://github.com/keeferrourke/la-capitaine-icon-theme.git'
	'https://github.com/unc926/OSX_ONE.git'
	'https://github.com/gusbemacbe/suru-plus.git'
)

function dumb_git() {
	TEMPSTART=$(pwd)
	BASE=$(basename $1 | sed 's/\.\w*$//')
	TEMPDEST=$(echo "$TEMPSTART/$BASE")
	if [ -d $BASE ];then
		echo "Pulling from URL: $1"
		cd $TEMPDEST && git pull
		cd $TEMPSTART
	else
		echo "Cloning from URL: $1"
		git clone $t
	fi
}

## Create associative array to rename repositories with a friendlier name
## SOURCE: http://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/
## To loop through all keys in array: 'for KEY in "${!RENAMEMAP[@]}"; do echo $KEY; done'
declare -A RENAMEMAP=(
	[adapta-gtk-theme]='Adapta-GTK'
	[la-capitaine-icon-theme]='La-Capitaine'
	[suru-plus]='Suru-Plus'
	[MacOSX_ONE8]='MacOSX-One8'
	[Cupertino-macOS-iCons]='Cupertino-MacOS'
)


## Clone GTK Themes
GTKDIR="$(echo $THEMEBASE)/GTK"
if [ ! -d $GTKDIR ];then
	printf "Creating GTK Themes Directory: ${bold}'$GTKDIR'${clean}\n"
	mkdir -p $GTKDIR
fi
cd $GTKDIR || break
printf "Begin cloning 'GTK' themes to directory: ${bold}'$GTKDIR'${clean}\n"
for t in "${GTKTHEMES[@]}"; do
	dumb_git $t
done
printf "Done cloning ${hilite}'GTK'${clean} themes from Git...\n"

## Clone Cursor Themes
CURSORDIR="$(echo $THEMEBASE)/Cursors"
if [ ! -d $CURSORDIR ];then
	printf "Creating Cursor Themes Directory: ${bold}'$CURSORDIR'${clean}\n"
	mkdir -p $CURSORDIR
fi
cd $CURSORDIR || break
printf "Begin cloning 'CURSOR' themes to directory: ${bold}'$CURSORDIR'${clean}\n"
for t in "${CURSORTHEMES[@]}"; do
	dumb_git $t
done
printf "Done cloning ${hilite}'CURSOR'${clean} themes from Git...\n"

## Clone Gogh Terminal Themes
TERMINALDIR="$(echo $THEMEBASE)/Terminal"
if [ ! -d $TERMINALDIR ];then
	printf "Creating Terminal Themes Directory: ${bold}'$TERMINALDIR'${clean}]\n"
	mkdir -p $TERMINALDIR
fi
cd $TERMINALDIR || break
printf "Begin cloning 'TERMINAL' themes to directory: ${bold}'$TERMINALDIR'${clean}\n"
for t in "${TERMINALDIR[@]}"; do
	dumb_git $t
done
printf "Done cloning ${hilite}'TERMINAL'${clean} themes from Git...\n"

## Clone Icon Themes
ICONDIR="$(echo $THEMEBASE)/Icons"
if [ ! -d $ICONDIR ];then
	printf "Creating Icon Themes Directory: ${bold}'$ICONDIR'${clean}\n"
	mkdir -p $ICONDIR
fi
cd $ICONDIR || break

printf "Begin cloning 'ICON' themes to directory: ${bold}'$ICONDIR'${clean}\n"
for t in "${ICONTHEMES[@]}"; do
	dumb_git $t
done
printf "Done cloning ${hilite}'ICON'${clean} themes from Git...\n"

printf "${bold}Done downloading all theme files!${clean}\n"
cd $ORIGDIR

## Find all 'index.theme' files within search path
INDEXFILES=$(find $THEMEBASE -maxdepth 5 -type f -name 'index.theme')

## Loop through all keys in the associative array (of 'index.theme' files)
for INDEX in $(find $THEMEBASE -maxdepth 5 -type f -name 'index.theme'); do
	# Get file's directory path & directory name
	DIRNAME=$(dirname $INDEX)
	DIRBASENAME=$(basename $DIRNAME)
	
	# Set theme type using directory name matches
	if [[ "$DIRNAME" =~ "Cursors" ]]; then
		#printf "Cursor theme detected - need to add logic for these...\n"
		DESTBASE=false
	elif [[ "$DIRNAME" =~ "Icons" ]]; then
		DESTBASE="/usr/share/icons"
	elif [[ "$DIRNAME" =~ "GTK" ]]; then
		#printf "GTK theme detected - need to add logic for these...\n"
		#DESTBASE="/usr/share/themes"
		DESTBASE=false
	elif [[ "$DIRNAME" =~ "Terminal" ]]; then
		#printf "Terminal theme detected - need to add logic for these...\n"
		DESTBASE=false
	else
		printf "Unknown theme type detected!!\n"
		DESTBASE=false
	fi

	if [ "$DESTBASE" = false ];then
		# Print empty line & skip moving index files with empty destination path
		printf ''		
	else
		# Check whether 'RENAMEMAP' array contains an alternate destination folder name
		if [ -n "${RENAMEMAP[$DIRBASENAME]}" ];then
			RENAME=${RENAMEMAP["$DIRBASENAME"]}
			DESTDIR="/usr/share/icons/$(echo $RENAME)"
		# Using the unmodified directory name
		else
			DESTDIR="/usr/share/icons/$(echo $DIRBASENAME)"
		fi
		
		printf "Copying theme ${hilite}'$DIRNAME'${clean} --> ${bold}'$DESTDIR'${clean}\n"	
		sudo cp -r $DIRNAME $DESTDIR
	fi
done


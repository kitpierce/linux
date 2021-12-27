ORIGDIR=$(pwd)
THEMEBASE="$(echo $HOME)/Git/Themes"

# Set clone destination sub-directory based on theme type
ICONDIR="$(echo $THEMEBASE)/Icons"
GTKDIR="$(echo $THEMEBASE)/GTK"
TERMINALDIR="$(echo $THEMEBASE)/Terminal"
CURSORDIR="$(echo $THEMEBASE)/Cursor"

## Set simple TPUT text formatting options
## USAGE: echo "this is ${BOLD_CYAN}bold cyan${CLEAR} text, this is ${BOLD_GREEN}${REVERSE}highlighted green${CLEAR}, and this is neither"

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

## Declare associative arrays of theme's Git URLs to download from
declare -A GTK_THEMES=(
	[https://github.com/adapta-project/adapta-gtk-theme]="${GTKDIR}/Adapta"
)

declare -A CURSOR_THEMES=(
    [https://github.com/KaizIqbal/Bibata_Cursor.git]="${CURSORDIR}/Bibata"
	[https://github.com/KaizIqbal/Google_Cursor.git]="${CURSORDIR}/Google"
)

declare -A TERMINAL_THEMES=(
    [https://github.com/Mayccoll/Gogh.git]="${TERMINALDIR}/Gogh"
	[https://github.com/mbadolato/iTerm2-Color-Schemes.git]="${TERMINALDIR}/iTerm2"
)

declare -A ICON_THEMES=(
	[https://github.com/vinceliuice/Tela-icon-theme.git]="${ICONDIR}/Tela"
	[https://github.com/keeferrourke/la-capitaine-icon-theme.git]="${ICONDIR}/La-Capitaine"
	[https://github.com/vinceliuice/WhiteSur-icon-theme.git]="${ICONDIR}/WhiteSur"
	[https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git]="${ICONDIR}/Papirus"
	[https://github.com/daniruiz/flat-remix.git]="${ICONDIR}/Flat-Remix"
)

# Wrapper function to clone new directories or pull existing directories
function pull-clone() {
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

    # A POSIX variable
    OPTIND=1         # Reset in case getopts has been used previously in the shell.

    # Initialize our own variables:
    local TEMPSTART=$(pwd)
    local SOURCE_URL=""
    local OUTPUT_DIR=""
    local VERBOSE="false"

    local SHOW_CALL=$(printf "${BOLD_LIME}[${FUNCNAME[0]}]${CLEAR} ")

    while getopts "h?vu:o:" opt; do
        case "$opt" in
            h|\?)
                printf "Usage: pull-clone -u https://github.com/author/repo.git -o ~/Git/local/directory"
                exit 0
                ;;
            v) 
                
                VERBOSE="true"
                printf "${SHOW_CALL}Setting 'VERBOSE' parameter: ${BOLD_CYAN}'$VERBOSE'${CLEAR}\n"
                ;;
            u)
                SOURCE_URL=$OPTARG
                printf "${SHOW_CALL}Setting 'SOURCE_URL' parameter: ${BOLD_CYAN}'$SOURCE_URL'${CLEAR}\n"
                ;;
            o)  
                OUTPUT_DIR=$OPTARG
                printf "${SHOW_CALL}Setting 'OUTPUT_DIR' parameter: ${BOLD_CYAN}'$OUTPUT_DIR'${CLEAR}\n"
                ;;
        esac
    done

    shift $((OPTIND-1))

    [ "${1:-}" = "--" ] && shift

    [[ "$VERBOSE" == "true" ]] && printf "${SHOW_CALL}Getting basename from ${BOLD_CYAN}'$SOURCE_URL'${CLEAR} source URL...\n"
    BASE=$(basename $SOURCE_URL | sed 's/\.\w*$//')

    [[ "$VERBOSE" == "true" ]] && printf "${SHOW_CALL}Checking whether 'OUTPUT_DIR' is defined...\n"

    if [[ "$OUTPUT_DIR" == "" ]];then 
        local BASE=$(basename $1 | sed 's/\.\w*$//')
        OUTPUT_DIR=$(echo "$TEMPSTART/$BASE")
        printf "${SHOW_CALL}Using inferred destination: ${BOLD_YELLOW}'$OUTPUT_DIR'${CLEAR}\n"
    else
        printf "${SHOW_CALL}Using explicit destination: ${BOLD_GREEN}'$OUTPUT_DIR'${CLEAR}\n"
    fi

    [[ "$VERBOSE" == "true" ]] && printf "${SHOW_CALL}Checking whether directory ${BOLD_CYAN}'$OUTPUT_DIR'${CLEAR} exists...\n"
	if [ -d "$OUTPUT_DIR" ];then
		printf "${SHOW_CALL}Directory exists ${BOLD_CYAN}'$OUTPUT_DIR'${CLEAR} - invoking ${BOLD_CYAN}'git pull'${CLEAR} for updates...\n"
		cd $OUTPUT_DIR && git pull && (
            printf "${SHOW_CALL}Finished ${BOLD_CYAN}'git pull'${CLEAR} for directory: ${BOLD_GREEN}'$OUTPUT_DIR'${CLEAR}\n"
        ) || (
            printf "${SHOW_CALL}Error for ${BOLD_YELLOW}'git pull'${CLEAR} on directory: ${BOLD_RED}'$OUTPUT_DIR'${CLEAR}\n"
        )
        cd $TEMPSTART
	else
		printf "${SHOW_CALL}Cloning from URL: ${BOLD_CYAN}'$SOURCE_URL'${CLEAR} into directory: '${BOLD_CYAN}${OUTPUT_DIR}${CLEAR}'\n"
		git clone "$SOURCE_URL" "$OUTPUT_DIR" && (
            printf "${SHOW_CALL}Finished clone from URL: ${BOLD_GREEN}'$SOURCE_URL'${CLEAR}\n"
        ) || (
            printf "${SHOW_CALL}Error cloning: ${BOLD_RED}'$SOURCE_URL'${CLEAR}\n"
        )
	fi
}

## Pre-seed sudo permissions (needed to install themes for all users)
printf "${SHOW_CALL}Testing for ${BOLD_CYAN}'sudo'${CLEAR} command access...\n"
sudo whoami >> /dev/null || break

## Create associative array to rename repositories with a friendlier name


### Loop through associative arrays: 
###     https://stackoverflow.com/a/3467959
###     http://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/
###
### To create associative array (note capital A flag)
#       declare -A animals=( ["moo"]="cow" ["woof"]="dog")
###
### To loop though key/value pairs in array:
###     for sound in "${!animals[@]}"; do echo "$sound - ${animals[$sound]}"; done
###
### To loop through all keys in array: 
###     for KEY in "${!animals[@]}"; do echo $KEY; done


# ## Clone GTK Themes
if [ ! -d "$GTKDIR" ];then
	printf "${SHOW_CALL}Creating GTK themes directory: ${BOLD_CYAN}'$GTKDIR'${CLEAR}\n"
	mkdir -p $GTKDIR
fi
cd $GTKDIR || break

printf "${SHOW_CALL}Begin cloning ${BOLD_MAGENTA}'GTK'${CLEAR} themes to directory: ${BOLD_CYAN}'$GTKDIR'${CLEAR}\n"
for REPO_URL in "${!GTK_THEMES[@]}"; do
    OUT_PATH="${GTK_THEMES[$REPO_URL]}"
    pull-clone -u "$REPO_URL" -o "$OUT_PATH"
done
printf "${SHOW_CALL}Done cloning ${BOLD_GREEN}'GTK'${CLEAR} themes from Git...\n"

## Clone Cursor Themes
if [ ! -d $CURSORDIR ];then
	printf "${SHOW_CALL}Creating Cursor Themes Directory: ${BOLD_CYAN}'$CURSORDIR'${CLEAR}\n"
	mkdir -p $CURSORDIR
fi
cd $CURSORDIR || break

printf "${SHOW_CALL}Begin cloning ${BOLD_MAGENTA}'CURSOR'${CLEAR} themes to directory: ${BOLD_CYAN}'$CURSORDIR'${CLEAR}\n"
for REPO_URL in "${!CURSOR_THEMES[@]}"; do
    OUT_PATH="${CURSOR_THEMES[$REPO_URL]}"
    pull-clone -u "$REPO_URL" -o "$OUT_PATH"
done
printf "${SHOW_CALL}Done cloning ${BOLD_GREEN}'CURSOR'${CLEAR} themes from Git...\n"

## Clone Terminal Themes
if [ ! -d $TERMINALDIR ];then
	printf "Creating Terminal themes directory: ${BOLD_CYAN}'$TERMINALDIR'${CLEAR}]\n"
	mkdir -p $TERMINALDIR
fi
cd $TERMINALDIR || break

printf "${SHOW_CALL}Begin cloning ${BOLD_MAGENTA}'TERMINAL'${CLEAR} themes to directory: ${BOLD_CYAN}'$TERMINALDIR'${CLEAR}\n"
for REPO_URL in "${!TERMINAL_THEMES[@]}"; do
    OUT_PATH="${TERMINAL_THEMES[$REPO_URL]}"
    pull-clone -u "$REPO_URL" -o "$OUT_PATH"
done
printf "${SHOW_CALL}Done cloning ${BOLD_GREEN}'TERMINAL'${CLEAR} themes from Git...\n"

## Clone Icon Themes
if [ ! -d "$ICONDIR" ];then
	printf "Creating Icon themes directory: ${BOLD_CYAN}'$ICONDIR'${CLEAR}\n"
	mkdir -p $ICONDIR
fi
cd $ICONDIR || break

printf "${SHOW_CALL}Begin cloning ${BOLD_MAGENTA}'ICON'${CLEAR} themes to directory: ${BOLD_CYAN}'$ICONDIR'${CLEAR}\n"
for REPO_URL in "${!ICON_THEMES[@]}"; do
    OUT_PATH="${ICON_THEMES[$REPO_URL]}"
    pull-clone -u "$REPO_URL" -o "$OUT_PATH"
done

printf "${SHOW_CALL}Done cloning ${BOLD_GREEN}'ICON'${CLEAR} themes from Git...\n"

printf "${SHOW_CALL}${BOLD_CYAN}Done downloading all theme files!${CLEAR}\n"
cd $ORIGDIR

### First attempt at auto-installing themes (using index.theme files) - this
### is DEFINITELY not production ready...

# ## Find all 'index.theme' files within search path
# INDEXFILES=$(find $THEMEBASE -maxdepth 5 -type f -iname 'index.theme')

# ## Loop through all keys in the associative array (of 'index.theme' files)
# for INDEX in $(find $THEMEBASE -maxdepth 5 -type f -name 'index.theme'); do
# 	# Get file's directory path & directory name
# 	DIRNAME=$(dirname $INDEX)
# 	DIRBASENAME=$(basename $DIRNAME)
	
# 	# Set theme type using directory name matches
# 	if [[ "$DIRNAME" =~ "Cursors" ]]; then
# 		#printf "Cursor theme detected - need to add logic for these...\n"
# 		DESTBASE=false
# 	elif [[ "$DIRNAME" =~ "Icons" ]]; then
# 		DESTBASE="/usr/share/icons"
# 	elif [[ "$DIRNAME" =~ "GTK" ]]; then
# 		#printf "GTK theme detected - need to add logic for these...\n"
# 		#DESTBASE="/usr/share/themes"
# 		DESTBASE=false
# 	elif [[ "$DIRNAME" =~ "Terminal" ]]; then
# 		#printf "Terminal theme detected - need to add logic for these...\n"
# 		DESTBASE=false
# 	else
# 		printf "Unknown theme type detected!!\n"
# 		DESTBASE=false
# 	fi

# 	if [ "$DESTBASE" = false ];then
# 		# Print empty line & skip moving index files with empty destination path
# 		printf ''		
# 	else
# 		# Check whether 'RENAMEMAP' array contains an alternate destination folder name
# 		if [ -n "${RENAMEMAP[$DIRBASENAME]}" ];then
# 			RENAME=${RENAMEMAP["$DIRBASENAME"]}
# 			DESTDIR="/usr/share/icons/$(echo $RENAME)"
# 		# Using the unmodified directory name
# 		else
# 			DESTDIR="/usr/share/icons/$(echo $DIRBASENAME)"
# 		fi
		
# 		printf "Copying theme ${hilite}'$DIRNAME'${CLEAR} --> ${BOLD_CYAN}'$DESTDIR'${CLEAR}\n"	
# 		sudo cp -r $DIRNAME $DESTDIR
# 	fi
# done


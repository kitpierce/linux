print_color() {
    # Create and invoke tput option to clear formatting
	CLEAR=$(tput sgr0);
	printf "${CLEAR}"

    # Set default values of for arguments
	FG_INT=''
	BG_INT=''
    ULINE=''
    BOLD=''
    INVERT=''
    END="\n"
	OTHER_ARGUMENTS=()

	# Loop through arguments and process them
    while (( $# )); do
        case $1 in
            -f|--fg|--foreground)
                FG_INT="$2"
                shift
                ;;
            -b|--bg|--background) 
                BG_INT="$2"
                shift
                ;;
            -B|--bold) 
                BOLD=$(tput bold)
                ;;
            -U|--underline) 
                ULINE=$(tput smul)
                ;;
            -I|--invert) 
                INVERT=$(tput smso)
                ;;
            -N|--nonewline) 
                END=''
                ;;                
            --)   
                shift;
                OTHER_ARGUMENTS+=( "$@" );
                set -- ;;
            *)
                OTHER_ARGUMENTS+=( "$1" ) ;;
        esac
        shift
    done

    # If foreground integer exists and is between 0 and 8
    [ -z "$FG_INT" ] || if (($FG_INT >= 0 && $FG_INT <= 8)); then
        # Use tput's 'setaf' method to set foreground color
        FG_COLOR=$(tput setaf $FG_INT)
        printf "${FG_COLOR}"
    fi

    # If background integer exists and is between 0 and 8
    [ -z "$BG_INT" ] || if (($BG_INT >= 0 && $BG_INT <= 8)); then
        # Use tput's 'setab' method to set background color
        BG_COLOR=$(tput setab $BG_INT)
        printf "${BG_COLOR}"
    fi

    # For switch options, invoke option if variable exists
    [ -z "$BOLD" ] || printf "${BOLD}"
    [ -z "$ULINE" ] || printf "${ULINE}"
    [ -z "$INVERT" ] || printf "${INVERT}"

    # Get length of an array
    ARR_COUNT=${#OTHER_ARGUMENTS[@]}

    # Use for loop to interate and print values
    for (( i=0; i<${ARR_COUNT}; i++ )); do
        printf "${OTHER_ARGUMENTS[$i]}"
    done

    # If 'END' is not set, only clear formatting; otherwise clear
    # formatting and wrap with newline
    [ -z "$END" ] && printf "${CLEAR}" || printf "${CLEAR}\n"
}

print_color -f 1 -b 8 'This is...' 'my text... ' -B -N
print_color -f 3 -b 8 'now I am....' -N
print_color -f 3 'inverting without background....' -N -I
print_color 'then clearing colors....' -N
print_color 'then inverting again....' 'and finally...' -N -I
print_color -f 5 -b 7 'done!' -B -I

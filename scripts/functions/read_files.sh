function import_colors () {
    HUE_RED=$(tput setaf 1)
    HUE_GREEN=$(tput setaf 2)
    HUE_YELLOW=$(tput setaf 3)
    HUE_CYAN=$(tput setaf 6)
    BOLD_RED=$(tput bold; tput setaf 1)
    BOLD_GREEN=$(tput bold; tput setaf 2)
    BOLD_YELLOW=$(tput bold; tput setaf 3)
    BOLD_LIME=$(tput bold; tput setaf 190)
    BOLD_POWDER=$(tput bold; tput setaf 153)
    BOLD_BLUE=$(tput bold; tput setaf 4)
    BOLD_MAGENTA=$(tput bold; tput setaf 5)
    BOLD_CYAN=$(tput bold; tput setaf 6)
    BOLD_WHITE=$(tput bold; tput setaf 7)
    CLEAR=$(tput sgr0)
    BLINK=$(tput blink)
    REVERSE=$(tput smso)
}

function read_files () {
    DEBUG=false

    if [[ -z "$1" ]];then
        HANDLE=$(pwd)
        printf "[${FUNCNAME[0]}] No input path, using current directory: "
        printf "${BOLD_CYAN}'$HANDLE'${CLEAR}\n"
    else
        HANDLE="$1"
    fi

    HANDLEPATH=$(resolve_path "$HANDLE") || (
        printf "[${FUNCNAME[0]}] Error resolving input path: "
        printf "${BOLD_RED}'$HANDLE'${CLEAR}\n"
        return 1
    )

    # Collect current working directory and IFS settings
    ODIR=$(pwd)
    OIFS="$IFS"

    # Set IFS to newline
    IFS=$'\n';

    for FILE in $(walk_files "$HANDLEPATH"); do
        if [[ $(command -v file) ]];then
            FILETYPE=$(file "$FILE" | cut -d' ' -f2) || FILETYPE='CANNOT_STAT'
        else
            FILETYPE='CANNOT_STAT'
        fi
        
        case "$FILETYPE" in
            CANNOT_STAT)
                cat_file "$FILE"
                ;;
            ASCII)
                cat_file "$FILE"
                ;;
            UTF-8)
                cat_file "$FILE"
                ;;

            PNG|JPEG)
                if [ "$DEBUG" = true ] ; then
                    printf "[${FUNCNAME[0]}] Skipping ${FILETYPE} image file: "
                    printf "${BOLD_YELLOW}'$FILE'${CLEAR}\n"
                fi
                ;;
            empty)
                if [ "$DEBUG" = true ] ; then
                    printf "[${FUNCNAME[0]}] File is empty: "
                    printf "${BOLD_YELLOW}'$FILE'${CLEAR}\n"
                fi
                ;;
            stop)
                stop
                ;;    
            *)
                if [ "$DEBUG" = true ] ; then
                    printf "[${FUNCNAME[0]}] Unsupported file type "
                    printf "${BOLD_RED}'$FILETYPE'${CLEAR}"
                    printf " for file: "
                    printf "${BOLD_CYAN}'$FILE'${CLEAR}\n"
                fi
    
        esac
        
    done

    # Restore original working directory and IFS settings
    IFS="$OIFS"
    cd "$ODIR"
}

function cat_file () {
    if [[ -z "$1" ]];then
        printf "[${FUNCNAME[0]}] ${BOLD_RED}Null function parameter...${CLEAR}\n"
        return 1
    else
        HANDLE=$(resolve_path "$1")
        if [[ -f "$HANDLE" ]];then
            printf "[${FUNCNAME[0]}] ${BOLD_GREEN}## BEGIN FILE: ${BOLD_CYAN}'${HANDLE}'${BOLD_GREEN} ##${CLEAR}\n";
            cat $HANDLE;
            printf "[${FUNCNAME[0]}] ${BOLD_GREEN}## END FILE: ${BOLD_CYAN}'${HANDLE}'${BOLD_GREEN} ##${CLEAR}\n";
        elif [[ -d "$HANDLE" ]];then
            printf "[${FUNCNAME[0]}] Input is directory, not a file: "
            printf "${BOLD_RED}'$HANDLE'${CLEAR}\n"
            return 1
        else
            printf "[${FUNCNAME[0]}] Input is neither file nor directory: "
            printf "${BOLD_RED}'$HANDLE'${CLEAR}\n"
            return 1
        fi
    fi
}

function resolve_path() {
    if [[ -z "$1" ]];then
        HANDLE=$(pwd)
    else
        HANDLE="$1"
    fi

    if [[ -d "$HANDLE" ]];then
        ODIR=$(pwd)
        # cd to desired directory; if fail, quell any error messages but return exit status
        cd "$1" 2>/dev/null || return $?

        # output full, link-resolved path
        echo "$(pwd -P)"

        cd "$ODIR"
    elif [[ -f "$HANDLE" ]];then
        DIRPATH=$(resolve_path $(dirname $HANDLE))
        echo "${DIRPATH}/$(basename $HANDLE)"
    else
        printf "[${FUNCNAME[0]}] Input is neither file nor directory: '$HANDLE'\n"
        return 1

    fi

}

function walk_files() {
    if [[ -z "$1" ]];then
        HANDLE=$(pwd)
    else
        HANDLE="$1"
    fi

    HANDLEPATH=$(resolve_path "$HANDLE") || (
        printf "[${FUNCNAME[0]}] Error resolving input path: "
        printf "${BOLD_RED}'${HANDLE}'${CLEAR}\n"
        return 1
    )

    if [[ -d "$HANDLEPATH" ]];then
        for SUB in $(ls -Bp "$HANDLEPATH"); do
            SUBPATH=$(resolve_path "${HANDLEPATH}/${SUB}") && (
                walk_files "$SUBPATH"
            ) || (
                printf "[${FUNCNAME[0]}] Error resolving sub-path: "
                printf "${BOLD_RED}'${SUBPATH}'${CLEAR}\n"
                return 1
            )
        done
    elif [[ -f "$HANDLEPATH" ]];then
        echo "${HANDLEPATH}"
    else
        printf "[${FUNCNAME[0]}] Input is neither file nor directory: '$HANDLEPATH'\n"
        return 1
    fi
}

import_colors

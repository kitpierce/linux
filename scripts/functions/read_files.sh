function read_files () {
    DEBUG=false

    BOLD_RED=$(tput bold; tput setaf 1)
    BOLD_YELLOW=$(tput bold; tput setaf 3)
    BOLD_CYAN=$(tput bold; tput setaf 6)
    CLEAR=$(tput sgr0)

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
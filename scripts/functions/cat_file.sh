function cat_file () {
    BOLD_RED=$(tput bold; tput setaf 1)
    BOLD_GREEN=$(tput bold; tput setaf 2)
    BOLD_YELLOW=$(tput bold; tput setaf 3)
    BOLD_CYAN=$(tput bold; tput setaf 6)
    CLEAR=$(tput sgr0)

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

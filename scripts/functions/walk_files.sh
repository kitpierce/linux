function walk_files() {
    BOLD_RED=$(tput bold; tput setaf 1)
    BOLD_GREEN=$(tput bold; tput setaf 2)
    BOLD_YELLOW=$(tput bold; tput setaf 3)
    BOLD_CYAN=$(tput bold; tput setaf 6)
    CLEAR=$(tput sgr0)

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

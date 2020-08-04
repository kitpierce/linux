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
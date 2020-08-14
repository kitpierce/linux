function find-file () {
    if [[ -z $1 ]];then
        read -p "Enter file name: " PATTERN
        printf "Searching for pattern: '$PATTERN'\n"
        find ./ -type f -iname "*$PATTERN*" | grep -i "$PATTERN" --color=always
    else
        for PATTERN in "$@"; do
            printf "Searching for pattern: '$PATTERN'\n"
            find ./ -type f -iname "*$PATTERN*" | grep -i "$PATTERN" --color=always
        done
    fi
}

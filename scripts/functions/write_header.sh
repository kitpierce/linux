function write_header() {
    # Set default variable values
    TPUTWIDTH=$(echo $(/usr/bin/tput cols))
    if [ $TPUTWIDTH -lt 80 ];then
        FILEWIDTH=$TPUTWIDTH
    else
        FILEWIDTH=80
    fi

    WIDTH=0
    CHAR='#'
    
    # Parse input arguments
    POSITIONAL=()
    while [[ $# -gt 0 ]]; do
        key="$1"

        case $key in
            -c|-char|--character)
                CHAR="$2"
                shift # past argument
                shift # past value
                ;;
            -w|--width)
                WIDTH="$2"
                shift # past argument
                shift # past value
                ;;
            -s|--string)
                POSITIONAL+=("$2")
                shift # past argument
                shift # past value
                ;;
            *)    # unknown option
                POSITIONAL+=("$1") # save it in an array for later

                shift # past argument
                ;;
        esac
    done

    # Find longest input string
    for x in ${POSITIONAL[@]};  do
        if [ ${#x} -gt $LONGEST ];  then
            LONGEST=${#x}
        fi
    done

    # https://stackoverflow.com/a/4410103/10961253
    PREFIX=$(printf '%s ' $(printf -- "${CHAR}%.0s" $(seq 3)))
    
    PADDEDLONG=$(($LONGEST + ${#PREFIX} + 3))
    if [ $PADDEDLONG -gt $FILEWIDTH ];then
        FILEWIDTH=$PADDEDLONG
    fi

    PADCHARS=$(printf -- "${CHAR}%.0s" $(seq $FILEWIDTH))
    printf '%s\n' "$PADCHARS"

    for INSTRING in "${POSITIONAL[@]}"; do
        # Trim leading and trailing spaces - see: https://unix.stackexchange.com/a/205854
        TRIMMED=$(echo $INSTRING | awk '{$1=$1;print}')
        FORMED="$PREFIX $TRIMMED "
        printf '%s' "$FORMED"
        printf '%*.*s\n' 0 $((FILEWIDTH - ${#FORMED} )) "$PADCHARS"
    done

    printf '%s\n' "$PADCHARS"
}

#write_header "This is my header..." 'Shorter...' "And another...." "..... and now the longest one of them all...." -char '-'
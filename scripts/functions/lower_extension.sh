#!/bin/bash

function lower_extension() {
    # Source: https://stackoverflow.com/a/11824856
    find . -depth -name '*.*' -type f -exec bash -c '
        base=${0%.*} ext=${0##*.} a=$base.${ext,,}; 
        if [[ "$a" != "$0" ]];then
            printf "Renaming file:\n\n\t$0\n\t$a\n\n";
            mv -- "$0" "$a"
        fi' {} \;
}

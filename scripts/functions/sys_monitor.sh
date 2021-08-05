function sys-monitor() {
    local BOLD_RED=$(tput bold; tput setaf 1)
    local CLEAR=$(tput sgr0)
    if [[ $(command -v htop) ]]; then
        htop --tree --delay=10 # --highlight-changes=1
    elif [[ $(command -v top) ]]; then
        top
    else
        printf "${BOLD_RED}No system monitoring tool found...${CLEAR}\n"
    fi
}
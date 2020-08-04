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

import_colors

### To use, dot-source this file (which invokes the 'import_colors'
### function), then use the variable names within printf statements.
# . ./import_colors.sh
# printf "This is ${BOLD_LIME}bold text....${BLINK}and blinking...${REVERSE}and reversed...${CLEAR}and cleared...\n"

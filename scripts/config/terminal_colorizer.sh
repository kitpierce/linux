#!/bin/bash

GITDIR="$HOME/Git/Terminal"
STARTDIR=$(pwd)

URL='https://github.com/mbadolato/iTerm2-Color-Schemes.git'



if [ ! $(command -v git) ];then
        printf "Required binary 'git' not found - quitting!\n"
else
        printf "Found required command: 'git'\n"
fi

if [ ! -d $GITDIR ];then
        printf "Creating Git directory for terminal themes: '$GITDIR'\n"
        mkdir -p $GITDIR
else    
        printf "Found Git directory for terminal themes: '$GITDIR'\n"
fi


cd $GITDIR
GITNAME=$(basename -- "$URL")
DIRNAME="$GITDIR/${GITNAME%.*}"

if [ -d $DIRNAME ];then
    printf "Git sub-directory exists: '$DIRNAME'\n"
    printf "Attempting update via 'git fetch'\n"
    cd "$DIRNAME"
    git fetch -v
else
    printf "Cloning URL: '$URL'\n"
    git clone $URL
    cd "$DIRNAME"
fi

if [ $(command -v konsole) ];then
    printf "Found terminal program: 'Konsole'\n"
    DESTPATH="$HOME/.local/share/konsole"
    if [ ! -d $DESTPATH ];then
        printf "Creating destination directory for themes: '$DESTPATH'\n"
        mkdir -p $DESTPATH
    else
        printf "Found theme destination directory: '$DESTPATH'\n"
    fi
    cp -uv $DIRNAME/konsole/*.colorscheme $DESTPATH
elif [ $(command -v gnome-terminal) ];then
    #printf "Found terminal program: 'Gnome-Terminal'\n"
    printf "Need to add 'Gnome-Terminal' functionality\n"
else
    printf "Terminal type not currently supported...\n"
fi

cd $STARTDIR

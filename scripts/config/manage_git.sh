#!/bin/bash

# Source: https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup

printf "Enter Git UserName:\t"
read -p "" gitname
printf "Setting Git UserName '$gitname'\n"
git config --global user.name "$gitname"

printf "Enter Git Email:\t"
read -p "" gitmail
printf "Setting Git Email '$gitmail'\n"
git config --global user.email "$gitmail"

printf "Setting Git global colorization options\n"
git config --global color.status auto
git config --global color.branch auto
git config --global color.interactive auto
git config --global color.diff auto

printf "\n### GIT CONFIG SUMMARY ###\n"
printf "$(git config --list)\n###END SUMMARY ###\n\n"

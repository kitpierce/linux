#!/bin/bash

#### References ####
# Regex Character Classes: https://www.gnu.org/software/sed/manual/html_node/Character-Classes-and-Bracket-Expressions.html
# TPUT Colors: https://stackoverflow.com/questions/4332478/read-the-current-text-color-in-a-xterm/4332530#4332530

TXT_GREEN=$(tput setaf 2)
TXT_YELLOW=$(tput setaf 3)
TXT_BLUE=$(tput setaf 4)
TXT_CLEAR=$(tput sgr0)

printf "${TXT_BLUE}Enter desired computer name...${TXT_CLEAR}\n"
read COMPNAME

SQUASHNAME=$(echo $COMPNAME | sed -E "s/([[:blank:]])+/ /g")
FORMATNAME=$(echo $COMPNAME | sed "s/[']//g"  | sed -E "s/([^[:alpha:][:digit:].-])+/-/g")

CURR_HOSTNAME=$(scutil --get HostName 2>&1)
CURR_LOCALNAME=$(scutil --get LocalHostName 2>&1)
CURR_COMPUTERNAME=$(scutil --get ComputerName 2>&1)

:<<'COMMENT'
printf "HostName:      $CURR_HOSTNAME"
printf "LocalHostName: $CURR_LOCALNAME"
printf "ComputerName:  $CURR_COMPUTERNAME"
printf "Provided Name: $COMPNAME"
printf "Squashed Name: $SQUASHNAME"
printf "Friendly Name: $FORMATNAME"
COMMENT

if [ "$COMPNAME" == "$SQUASHNAME" ]; then
  printf "Using user-provided computer name: ${TXT_GREEN}'$SQUASHNAME'${TXT_CLEAR}\n"
else
  printf "Using formatted computer name value: ${TXT_GREEN}'$SQUASHNAME'${TXT_CLEAR}\n"
fi

if [ "$FORMATNAME" != "$SQUASHNAME" ]; then
  printf "Using network-friendly name value: ${TXT_GREEN}'$FORMATNAME'${TXT_CLEAR}\n"
fi


#if [ $CURR_COMPUTERNAME == $SQUASHNAME ]; then
if [ "$CURR_COMPUTERNAME" == "$SQUASHNAME" ]; then
  printf "Current ComputerName value already ${TXT_GREEN}'$SQUASHNAME'${TXT_CLEAR}\n"
else
  printf "Setting ComputerName value:\t ${TXT_YELLOW}'$SQUASHNAME'${TXT_CLEAR}\n"
  sudo scutil --set ComputerName $SQUASHNAME
fi

#if [ $CURR_HOSTNAME == $FORMATNAME ]; then
if [ "$CURR_HOSTNAME" == "$FORMATNAME" ]; then
  printf "Current HostName value already ${TXT_GREEN}'$FORMATNAME'${TXT_CLEAR}\n"
else
  printf "Setting HostName value:\t\t ${TXT_YELLOW}'$FORMATNAME'${TXT_CLEAR}\n"
  sudo scutil --set HostName $FORMATNAME
fi

#if [ $CURR_LOCALNAME == $FORMATNAME ]; then
if [ "$CURR_LOCALNAME" == "$FORMATNAME" ]; then
  printf "Current LocalHostName value already ${TXT_GREEN}'$FORMATNAME'${TXT_CLEAR}\n"
else
  printf "Setting LocalHostName value:\t ${TXT_YELLOW}'$FORMATNAME'${TXT_CLEAR}\n"
  sudo scutil --set LocalHostName $FORMATNAME
fi

sudo dscacheutil -flushcache

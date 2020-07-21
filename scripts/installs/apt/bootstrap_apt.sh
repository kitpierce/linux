#!/bin/bash
sudo whoami > /dev/null || (echo "Failed 'sudo' authentication test" && return 1)

DESIRED=("whois" "aptitude" "vim" "bash-completion" "htop" "iotop" "git-cola" "git-gui")
NEEDED=()
INSTALLED=()

echo "Collecting list of currently installed packages (apt list --installed)"
for PACKAGE in $(sudo apt list --installed | sed 's#\/.*$##' | grep -Ev '^(WARNING:|Listing\.\.\.|$)');do
	INSTALLED=( "${INSTALLED[@]}" "$PACKAGE" );
done

# To add an element
#INSTALLED=( "${INSTALLED[@]}" "new_element1" "new_element2" "..." "new_elementN")

echo "Testing whether desired packages are currently installed"
for WANT in "${DESIRED[@]}";do
	if [[ ${INSTALLED[*]} =~ "$WANT" ]]; then
		echo -e "\tPackage already installed: '$WANT'"
	else
		if [[ $(apt-cache search --names-only "$WANT") ]]; then
			NEEDED=( "${NEEDED[@]}" "$WANT" )
			echo -e "\tAdding package to installation list: '$WANT'"
		else
			echo -e "\tPackage not available in apt cache: '$WANT'"
		fi
	fi
done

if [ "${#NEEDED[@]}" -eq 0 ]; then
	echo "All desired packages installed - total count: '${#DESIRED[@]}'"
else
	echo "Requesting installation of ${#NEEDED[@]} packages"
	#IFS=$'\n';
	echo "Package list: ${NEEDED[*]}"
	sudo apt install ${NEEDED[*]} -y || (
		echo "Failed bulk installation, initiating per-package installation"
		for NEED in "${NEEDED[@]}";do
			echo "Installing individual package: '$NEED'"
			sudo apt install $NEED -y || echo "Failed installation for package: '$NEED'"
		done
	)
fi

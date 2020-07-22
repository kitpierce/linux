#!/bin/bash
sudo whoami > /dev/null || (echo "Failed 'sudo' authentication test" && return 1)

DESIRED=("curl" "whois" "aptitude" "vim" "bash-completion" "htop" "iotop" "git-cola" "apt-file")
NEEDED=()
ADDED=()
INSTALLED=()

echo "Collecting list of currently installed packages (dpkg --list)"
for PACKAGE in $(dpkg --list | grep -E '^ii' | awk '{print $2}');do
	INSTALLED=( "${INSTALLED[@]}" "$PACKAGE" );
done
echo "Currently installed package count: '${#INSTALLED[@]}'"

# To add an element
#INSTALLED=( "${INSTALLED[@]}" "new_element1" "new_element2" "..." "new_elementN")

echo "Testing whether desired packages are currently installed"
for WANT in "${DESIRED[@]}";do
	if [[ ${INSTALLED[*]} =~ ($|[[:space:]])"$WANT"($|[[:space:]]) ]]; then
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
			sudo apt install $NEED -y && ADDED=( "${ADDED[@]}" "$NEED" ) || echo "Failed installation for package: '$NEED'"
		done
	)
fi

if [[ ${ADDED[*]} =~ "aptitude" ]]; then
	echo "Updating cache for recently installed package manager: 'aptitude'"	
	sudo aptitude update -y
elif [[ ${ADDED[*]} =~ "apt-file" ]]; then
	echo "Updating apt-file package cache"
	sudo apt-file update --verbose
fi

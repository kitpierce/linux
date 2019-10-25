function install_vscode_apt {
    ## Reference: https://code.visualstudio.com/docs/setup/linux

    # Select version to be installed: 'code' or 'code-insiders'
    VERSION='code'

    if [ ! $(command -v 'curl') ];then
	    printf "Required binary 'curl' is not installed\n"
	    return 1
    fi
    
    # Set file names
    GPG_FILE='microsoft.gpg'
    REPO_FILE='/etc/apt/sources.list.d/vscode.list'

    # Check whether VSCode is already installed
    if [[ $(command -v $VERSION) ]];then
        printf "Visual Studio Code already installed: '$(command -v $VERSION)'\n"
        return 0
    fi

    # Test sudo permission elevation
    sudo whoami >> /dev/null || (
        printf "Failed permissions elevation -  quitting.\n"
        return 1
    )

    # Download GPG key to file
    printf "Downloading Microsoft GPG key\n"
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > $GPG_FILE

    # Add GPG key to trusted keys
    printf "Installing Microsoft GPG key to: '/etc/apt/trusted.gpg.d/'\n"
    sudo install -o root -g root -m 644 $GPG_FILE /etc/apt/trusted.gpg.d/ && sudo rm $GPG_FILE

    # Create apt repository file
    printf "Creating VSCode repository file: '$REPO_FILE'\n"
    sudo sh -c "echo 'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main' > $REPO_FILE"

    # Install prerequisite package
    for PKG in 'apt-transport-https';do
        # Test whether package is installed using 'apt-cache policy'
        if [[ $(apt-cache policy $PKG | grep -i installed | grep -i '(none)') ]];then
            printf "Installing prerequisite package: '$PKG'\n"
            sudo apt-get install $PKG -y || (
                printf "Failed install of prerequisite: '$PKG'\n"
                return 1
            )
        fi
    done

    # Install VSCode
    printf "Installing Visual Studio Code\n"
    sudo apt-get update && sudo apt-get install $VERSION -y && return 0 || (
        printf "Installation failed for Visual Studio Code\n"
        return 1
    )
}

function install_vscode_rpm {
    ## Reference: https://code.visualstudio.com/docs/setup/linux

    # Select version to be installed: 'code' or 'code-insiders'
    VERSION='code'

    # Set file names
    REPO_FILE='/etc/yum.repos.d/vscode.repo'

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
    printf "Importing Microsoft GPG key\n"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

    # Create apt repository file
    printf "Creating VSCode repository file: '$REPO_FILE'\n"
    sudo sh -c "echo -e '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc' > $REPO_FILE"

    # Install VSCode
    if [ $(command -v dnf) ];then
        printf "Installing Visual Studio Code via 'dnf' tool\n"
        dnf check-update && sudo dnf install $VERSION

    elif [ $(command -v yum) ];then
        printf "Installing Visual Studio Code via 'yum' tool\n"
        yum check-update && sudo yum install $VERSION
    else
        printf "Cannot locate 'dnf' or 'yum' package manager\n"
        return 1
    fi
}

install_vscode_rpm
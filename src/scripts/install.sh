#!/bin/bash
# set smart sudo
if [[ $EUID == 0 ]]; then
       	export SUDO=""
else 
	export SUDO="sudo"
fi

#check if semver is installed
if ! command -v semver &> /dev/null; then
        echo "Installing semver"
        $SUDO wget -qO /usr/local/bin/semver https://raw.githubusercontent.com/fsaintjacques/semver-tool/master/src/semver
        $SUDO chmod +x /usr/local/bin/semver
fi

#check if GitHub cli is installed
if ! command -v gh &> /dev/null; then
	curl -sSL "https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_linux_amd64.deb" -o "gh-cli.deb"
	$SUDO apt install ./gh-cli.deb
	rm gh-cli.deb
fi

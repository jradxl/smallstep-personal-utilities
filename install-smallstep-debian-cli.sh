#!/bin/bash

echo "Smallstep : Getting Remote Versions..."
rcaVersion=$(git -c 'versionsort.suffix=-' \
    ls-remote --exit-code --refs --sort='version:refname' --tags https://github.com/smallstep/certificates.git '*.*.*' \
    | tail --lines=1 \
    | cut --delimiter='/' --fields=3)
    
rcaVersion="${rcaVersion:1}"
echo "Remote CA Verion: $rcaVersion"

rcliVersion=$(git -c 'versionsort.suffix=-' \
    ls-remote --exit-code --refs --sort='version:refname' --tags https://github.com/smallstep/cli.git '*.*.*' \
    | tail --lines=1 \
    | cut --delimiter='/' --fields=3)

rcliVersion="${rcliVersion:1}"
echo "Remote CLI Verion: $rcliVersion"

rstepcadeb="https://github.com/smallstep/certificates/releases/download/v${rcaVersion}/step-ca_${rcaVersion}_amd64.deb"
# https://github.com/smallstep/certificates/releases/download/v0.19.0/step-ca_0.19.0_amd64.deb
# https://github.com/smallstep/certificates/releases/download/v0.19.0/step-ca_linux_0.19.0_amd64.tar.gz
rstepcadeb="https://github.com/smallstep/certificates/releases/download/v${rcaVersion}/step-ca_${rcaVersion}_amd64.deb"
rstepcabin="https://github.com/smallstep/certificates/releases/download/v${rcaVersion}/step-ca_linux_${rcaVersion}_amd64.tar.gz"

# https://dl.step.sm/gh-release/cli/docs-cli-install/v0.19.0/step-cli_0.19.0_amd64.deb
# https://files.smallstep.com
# https://github.com/smallstep/cli/releases/download/v0.19.0/step-cli_0.19.0_amd64.deb
# https://github.com/smallstep/cli/releases/download/v0.19.0/step_linux_0.19.0_amd64.tar.gz
rstepclideb="https://github.com/smallstep/cli/releases/download/v${rcliVersion}/step-cli_${rcliVersion}_amd64.deb"
rstepclibin="https://github.com/smallstep/cli/releases/download/v${rcliVersion}/step_linux_${rcliVersion}_amd64.tar.gz"

#SSH-HOST
# https://dl.step.sm/s3/ssh/docs-ssh-host-step-by-step/step-ssh_latest_amd64.deb

echo "  Installing Step CLI Debian Package..."
wget --timeout=30 --tries=3 -O step-ca.deb --quiet "${rstepclideb}"
if [[ $? != 0 ]]; then
    echo "  Downloading error, quitting..."
    exit 1
fi
sudo dpkg -i step-ca.deb > /dev/null 2>/dev/null       
if [[ $? != 0 ]]; then
    echo "  Installing error, quitting..."
    exit 1
fi

echo "Following Smallstep Debian Packages are Installed..."
apt list --installed 2>/dev/null | grep ^step

exit 0


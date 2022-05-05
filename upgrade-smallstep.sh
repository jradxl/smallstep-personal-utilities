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



echo ""
echo "Smallstep : Getting Local Versions..."

echo "  Following Smallstep Debian Packages are Installed..."
#ret=$(apt list --installed 2>/dev/null | grep ^step-cli)
#echo "  $ret"
#ret=$(apt list --installed 2>/dev/null | grep ^step-ca)
#echo "  $ret"
apt list --installed 2>/dev/null | grep ^step
echo ""

##Not using apt in script decisions
$(dpkg-query -l step-cli > /dev/null 2>&1)
if [[ $? == 0 ]]; then
    stepclideb=1
else
    stepclideb=0
fi

$(dpkg-query -l step-ca > /dev/null 2>&1)
if [[ $? == 0 ]]; then
    stepcadeb=1
else
    stepcadeb=0
fi

#Test version in binary, irrespective of whether Package or Binary installed
if ! command -v step-cli &> /dev/null
then
    echo "Step CLI Package not found. Looking for step binary only..."
    nostepcli=0
    if ! command -v step &> /dev/null
    then
        echo "Step CLI Binary not found."
        nostepcli=1
    else
        lcliVersion=$(step --version)
        if [[ "$lcliVersion" == *"$Smallstep"* ]]; then
            lcliVersion=${lcliVersion:14:6}
            echo "Installed Step CLI Binary version: $lcliVersion"
        fi   
    fi
else
    lcliVersion=$(step-cli --version)
    if [[ "$lcliVersion" == *"$Smallstep"* ]]; then
        lcliVersion=${lcliVersion:14:6}
        echo "Installed Step CLI Package version: $lcliVersion"
    fi    
fi

nostepca=0
if ! command -v step-ca &> /dev/null
then
    echo "Step CA not found."
    nostepca=1
else
    lcaVersion=$(step-ca --version)
    if [[ "$lcaVersion" == *"$Smallstep"* ]]; then
        lcaVersion=${lcaVersion:13:6}
        echo "Installed Step CA version: $lcaVersion"
    fi   
fi

echo ""

#TEST lcliVersion="0.18.0"

if [[ nostepcli == 0 ]]; then
    if [[ $rcliVersion == $lcliVersion ]]; then
        echo "No Step CLI upgrade needed"
    else
        echo "Upgrading Step CLI"
        if [[ $stepclideb == 1 ]]; then
            echo "  Installing Step CLI Debian Package..."
            wget --timeout=30 --tries=3  -O step-cli.deb --quiet "${rstepclideb}"
            
            if [[ $? != 0 ]]; then
                echo "  Downloading error, quitting..."
                exit 1
            fi
            sudo dpkg -i step-cli.deb >/dev/null 2>/dev/null
            if [[ $? != 0 ]]; then
                echo "  Installing error, quitting..."
                exit 1
            fi
         else
            echo "  Installing Step CLI Binary..."       
            wget --timeout=30 --tries=3 --quiet -O step.tar.gz $rstepclibin
            if [[ $? != 0 ]]; then
                echo "  Downloading error, quitting..."
                exit 1
            fi
            tar -xf step.tar.gz
            sudo cp step_${rcliVersion}/bin/step /usr/bin
            rm -f  step.tar.gz >/dev/null 2>/dev/null
            rm -rf step_${rcliVersion} >/dev/null 2>/dev/null          
        fi
        echo "Step CLI Install Success"
    fi
fi

#TEST lcaVersion=1.18.0
if [[ nostepca == 0 ]]; then
    if [[ $rcaVersion == $lcaVersion ]]; then
        echo "No Step CA upgrade needed"
    else
        echo "Upgrading Step CA"
        if [[ $stepcadeb == 1 ]]; then
            echo "  Installing Step CA Debian Package..."
            wget --timeout=30 --tries=3 -O step-ca.deb --quiet "${rstepcadeb}"
            if [[ $? != 0 ]]; then
                echo "  Downloading error, quitting..."
                exit 1
            fi
            sudo dpkg -i step-ca.deb > /dev/null 2>/dev/null       
            if [[ $? != 0 ]]; then
                echo "  Installing error, quitting..."
                exit 1
            fi
        else
            echo "  Installing Step CA Binary..."       
            wget --timeout=30 --tries=3 --quiet -O step-ca.tar.gz $rstepcabin
            if [[ $? != 0 ]]; then
                echo "  Downloading error, quitting..."
                exit 1
            fi
            tar -xf step-ca.tar.gz
            sudo cp step-ca_${rcliVersion}/bin/step-ca /usr/bin
            rm -f  step-ca.tar.gz >/dev/null 2>/dev/null
            rm -rf step-ca_${rcliVersion} >/dev/null 2>/dev/null

        fi
        echo "Step CA Install Success"  
    fi
fi

rm -f *.deb >/dev/null 2>/dev/null

exit 0


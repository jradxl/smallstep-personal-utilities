#!/bin/bash
echo "Installing Step CA..."

if [[ ! -f ".env" ]]; then
    echo "No .env file exists. Quitting"
else
    source .env
    echo ".env file sourced"
fi

if [[ ! -f "$PASSWD1" ]]; then
    echo "No $PASSWD1  file exists. Quitting"
fi

if [[ ! -f "$PASSWD2" ]]; then
    echo "No $PASSWD2  file exists. Quitting"
fi

export STEPPATH=$(step-cli path)
echo "Current Step Path is: $STEPPATH"

datetime=$(date +"%Y%m%d%H%M%S")
echo "Current Time is: $datetime"

echo "Using..."
echo $WITHCAURL
echo $PROVISIONER1
echo $ADDRESS
echo $NAME
echo $DNS1
echo $DNS2
echo $PASSWD1
echo $PASSWD2

#step ca init [--root=file] [--key=file] [--pki] [--ssh] [--helm]
#[--deployment-type=name] [--name=name] [--dns=dns] [--address=address]
#[--provisioner=name] [--provisioner-password-file=file] [--password-file=file]
#[--ra=type] [--kms=type] [--with-ca-url=url] [--no-db] [--context=name]
#[--profile=name] [--authority=name]

step-cli ca init --ssh \
--deployment-type=standalone \
--with-ca-url=$WITHCAURL \
--provisioner=$PROVISIONER1 \
--address=$ADDRESS \
--name=$NAME \
--dns=$DNS1 \
--dns=$DNS2 \
--password-file=$PASSWD1 \
--provisioner-password-file=$PASSWD2

# These arguments are for use with multiple CAs
# --authority=jsrauth --profile=jsrprof --context=jsrctext
                 
tar cf stepbakup-${datetime}.tar ~/.step
                 
exit 0

## For systemd use
## https://smallstep.com/docs/step-ca/certificate-authority-server-production

sudo useradd --system --home /etc/step-ca --shell /bin/false step
sudo cp -r $STEPPATH  /etc/step-ca/
NOTE: TODO, update paths in ca.json and defaults.json
cp $PASSWD1 /etc/step-ca/password.txt
chmod 600  /etc/step-ca/password.txt 
chown -R step:step /etc/step-ca
mkdir /etc/step-ca/db


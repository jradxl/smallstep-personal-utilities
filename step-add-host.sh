#!/bin/bash -e
#NB Can't use -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

source .env

LOCAL_HOSTNAME=$(hostname -s)
HOSTNAME=$(hostname -f)
SERVER_IP=$(hostname -i)

echo "Setting up Server: ${HOSTNAME}, ${LOCAL_HOSTNAME}, ${SERVER_IP}"
echo "Using Provisioners: JWK: ${JWK_PROVISIONER}, X5C: ${X5C_PROVISIONER}"
echo ""
echo "Setting Bootstap..."
step ca bootstrap --force --ca-url $CA_URL --fingerprint $CA_FINGERPRINT

echo ""
echo "Step Path is: $(step path)"
echo ""
echo "Configuration is: "
cat $(step path)/config/defaults.json

echo ""
echo "Installing the Root certificate..."
##step ssh config --roots > $(step path)/certs/ssh_user_key.pub
CACERT=$(step ssh config --roots)
#echo "CERT: ${CACERT}"
echo "${CACERT}" > $(step path)/certs/ssh_user_key.pub
TCAFILE="trusted-cert-list.pub"
TCAPATH="/etc/ssh/sshd_config.d"
TCAFILENAME="$TCAPATH/$TCAFILE"
if [[ -f $TCAFILENAME ]]; then
        echo "File $TCAFILE found. Checking whether to merge..."
        RET=$(grep -Fx "$CACERT" "$TCAFILENAME")
        RET=$?
        case $RET in
        0)
          # code if found
          echo "Already in file. Not merging."
          ;;
        1)
          # code if not found
          echo "Merging into file"
          echo "${CACERT}" >> $TCAFILENAME
          ;;
        *)
          # code if an error occurred
          echo "Error merging."
          exit 1
          ;;
        esac
else
        echo "Creating ${TCAFILE} file and adding cert"
        echo "${CACERT}" > $TCAFILENAME
fi

echo ""
echo "Getting TOKEN from Provisioner: ${JWK_PROVISIONER} ..."
TOKEN=$(step ca token ${HOSTNAME} --ssh --host --provisioner "${JWK_PROVISIONER}" --principal ${LOCAL_HOSTNAME} --principal ${HOSTNAME} --principal  ${SERVER_IP})

sleep 1

echo ""
echo "Signing X5C certificate for SSH Host..."
step ssh certificate ${HOSTNAME}  /etc/ssh/ssh_host_ecdsa_key.pub \
         --host --sign --provisioner "${X5C_PROVISIONER}" \
         --principal ${LOCAL_HOSTNAME} --principal ${HOSTNAME} --principal  ${SERVER_IP} \
         --token $TOKEN

echo ""
echo "Moving cert to Ubuntu specfic sshd_config.d to avoid issues on upgrades..."
mv /etc/ssh/ssh_host_ecdsa_key-cert.pub /etc/ssh/sshd_config.d/
step ssh inspect /etc/ssh/sshd_config.d/ssh_host_ecdsa_key-cert.pub

cat <<EOF > /etc/ssh/sshd_config.d/ssh-host-config.conf
# SSH CA Configuration

# This is the CA's public key, for authenticatin user certificates:
# There should be only one instance of this directive.
TrustedUserCAKeys ${TCAFILENAME}

# This is our host private key and certificate:
HostKey /etc/ssh/ssh_host_ecdsa_key
HostCertificate /etc/ssh/sshd_config.d/ssh_host_ecdsa_key-cert.pub
EOF

echo ""
echo "Adding a Cron Weekly Job..."
# Now add a weekly cron script to rotate our host certificate.
cat <<EOF > /etc/cron.weekly/rotate-ssh-certificate
#!/bin/sh

export STEPPATH=/root/.step

step ssh renew /etc/ssh/sshd_config.d/ssh_host_ecdsa_key-cert.pub /etc/ssh/ssh_host_ecdsa_key --force 2> /dev/null

exit 0
EOF

chmod 755 /etc/cron.weekly/rotate-ssh-certificate

echo ""
echo "Restarting SSHD"
systemctl restart sshd

exit 0


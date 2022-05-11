#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: ssh.sh <user@example.com>"
    exit 1
else
    echo $1 
fi


REGEX1="^(([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))\.)*([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))@\w((-|\w)*\w)*\.(\w((-|\w)*\w)*\.)*\w{2,4}$"
REGEX="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"


oldIFS="$IFS"
IFS="@" read -r username domain <<< "$1"
echo "Username: $username"
echo "Domain: $domain"
IFS=$oldIFS
        
RET=$(step ssh check-host -v "$domain")

if [[ $RET == "true" ]]; then
    echo "Domain [$domain] is supported by Smallstep"
fi

KEYS=$(ssh-add -L)

case "$KEYS" in
    *$username*) 
        echo "Username $username found in currently loaded keys"
        echo "Succes: You can try to login with ssh"
        ssh $1
     ;;
    *) 
        echo "No Key found. You must make a SmallStep login..."
        while true; do
            read -r -p "Please enter your Keycloak Login Address ([Q/q]uit): " answer
            case $answer in
                 *[@]*) 
                    if [[ $answer =~ $REGEX ]] ; then
                        echo "OK: $answer"
                        break
                    else
                        echo "not OK: $answer"
                    fi
                 ;;
                 [Qq]*)
                    echo "Bye"
                    exit 0
                    break
                 ;;             
                 *)
                    echo "Please enter a valid Smallstep Login email address <user@example.com>"
                 ;;
            esac
        done
        TMPFILE=$(mktemp)
        trap "rm -f $TMPFILE" 0 2 3 15     
        RET1=$(step ssh login --provisioner "KeyCloak1" $answer 2>$TMPFILE)
        RET2=$?
        #echo "STDOUT DATA: $RET1"
        #echo "RET Step Login: $RET2"
        if [[ $RET2 != 0 ]]; then 
            RET3=$(grep "The request was forbidden by the certificate authority" "$TMPFILE")
            #echo $RET3
        else
            echo ""
            echo "Success: You can try to login with ssh"
            ssh $1
        fi
        
        rm $TMPFILE  
     ;;
esac

exit 0


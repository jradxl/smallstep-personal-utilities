#!/bin/bash
##NB can't use -e

##  export STEPPATH=~/.step

echo "Smallstep Health..."

WHICHSTEP=$(which step)
if [[ $WHICHSTEP != *"step"* ]]; then
    echo "Smallstep CLI not found"
    exit 1
fi

HEALTH=$(step ca health)
if [[ $HEALTH != "ok" ]]; then
    echo "CA Server Unhealthy!"
    exit 1
fi

if [[ $STEPPATH == "" ]]; then
    echo "STEPPATH not set"
else
    echo "STEPPATH is set to: ${STEPPATH}"
fi

STEPP=$(step path)
if [[  $STEPP != *".step"* ]]; then
    echo "No Step Path"
    exit 1
else
    echo "step path resolves to: ${STEPP}"
fi

FILE=$(step path)/config/defaults.json
if [[ ! -f "${FILE}" ]]; then
    echo "Configuration file defaults.json does not exist"
    exit 1
else
    echo "defaults.json is:-"
    cat ${FILE}
fi

echo ""
echo "Smallstep Health OK!"
exit 0


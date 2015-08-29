#!/bin/bash
# Install vmware fusion guest tools
# Use standard build environment layout
#set -e && . "$(dirname "$0")/ws-env.sh" && SCRIPTNAME="$(basename "$0")"

echo You must first go to VMWare Fusion command line
echo and click on install vmware toosl

# Note that quotes gets rid of wild cards etc
# Use -f to force the copy
cp -f "/media/$USER"/VM*/VM*.gz "$HOME/Downloads"
tar xf "$HOME/Downloads"/VM*.gz
sudo "$HOME/Downloads"/vmware*/vm*.pl

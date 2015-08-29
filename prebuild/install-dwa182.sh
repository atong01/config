#!/bin/bash
# 
## Install the D-link DWA-182 wifi adapter 
## Really this is the Realtek RTL8812AU or RTL8821AU driver
## @author Rich
#
# set -eo pipefail && . `dirname $0`/ws-env.sh && SCRIPTNAME=$(basename $0)
set -eo pipefail && SCRIPTNAME=$(basename $0)

if ! lsusb | grep "2001:3315 D-Link"
then
    echo "No DWA-182 found"
    exit 1
fi

sudo apt-get install -y linux-headers-generic build-essential git
cd ~/ws/git

if [ ! -e rtl8812AU_8821AU_linux ]
then
    git clone git@github.com:abperiasamy/rtl8812AU_8821AU_linux.git
fi

cd rtl8812AU_8821AU_linux
make

sudo make install
sudo modprobe 8812au

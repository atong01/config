#!/bin/bash

#raspi-setup.sh
#Created By Alex Tong February 20, 2015
#
# This script setups a raspberry pi running raspbian how I like it.
#
#
#


apt-get update -y -q
apt-get upgrade -y -q
echo installing vim
apt-get install vim -y -q
echo installing samba
apt-get install samba -y -q
echo installing tightvncserver
apt-get install tightvncserver -y -q
echo starting vnc server port 5901
vncserver :5901 -geometry 1028x768 -depth 24
echo auto-start vnc server at boot time port 5901
cp vncboot /etc/init.d/vncboot
update-rc.d /etc/init.d/vncboot defaults
chmod 755 /etc/init.d/vncboot

echo running regular setup script
sh setup.sh

#!/bin/bash

#setup.sh
#Created By Alex Tong January 28, 2015
#Modified By Alex Tong February 16, 2015
#This script runs the config package to set up a remote linux machine

echo "Running ssh-config.sh"
./ssh-config.sh
echo "copying .vimrc"
cp .vimrc ~
echo "changing bash prompt"
echo "#bash prompt change by Alex Tong" >> ~/.bashrc
echo "PS1=\h:\w $ " >> ~/.bashrc

echo "setup complete"

###############################################################################
#END OF FILE
###############################################################################

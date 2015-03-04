#!/bin/bash

#setup.sh
#Created By Alex Tong January 28, 2015
#Modified By Alex Tong February 16, 2015
#This script runs the config package to set up a remote linux machine

echo "Running ssh-config.sh"
./ssh-config.sh
echo "copying .vimrc"
cp .vimrc ~
echo "changing prompt"
if [ $SHELL == /bin/tcsh ]; then
    echo tcsh
    echo "#tcsh prompt change by Alex Tong" >> ~/.bashrc
    echo "\"PS1=\h:\w $ \"" >> ~/.bashrc
elif [ $SHELL == /bin/bash ]; then
    echo bash
    echo "#bash prompt change by Alex Tong" >> ~/.bashrc
    echo "\"PS1=\h:\w $ \"" >> ~/.bashrc
else
    echo shell not found
fi

echo "setup complete"

###############################################################################
#END OF FILE
###############################################################################

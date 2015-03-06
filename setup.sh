#!/bin/bash

#setup.sh
#Created By Alex Tong January 28, 2015
#Modified By Alex Tong February 16, 2015
#This script runs the config package to set up a remote linux machine

echo "Running ssh-config.sh"
./ssh-config.sh
echo "copying .vimrc"
cp .vimrc ~
###############################################################################
echo "changing prompt"
printf "Ok to change prompt?"
read X
case "$X" in
    y*|Y*) 
        if [ $SHELL == /bin/tcsh ]; then
            echo tcsh
            echo "#tcsh prompt change by Alex Tong" >> ~/.cshrc
            echo "set prompt = \'%~ > \'" >> ~/.cshrc
        elif [ $SHELL == /bin/bash ]; then
            echo bash
            echo "#bash prompt change by Alex Tong" >> ~/.bashrc
            echo "\"PS1=\h:\w $ \"" >> ~/.bashrc
        else
            echo shell not found
        fi
    ;;
    *)
esac
###############################################################################
echo "setup complete"

###############################################################################
#END OF FILE
###############################################################################

#!/bin/bash

#shelltest.sh
#Created By Alex Tong March 4, 2015
#Modified By Alex Tong March 4, 2015
#This script does testing on what shell we are using by the shell enviroment variable, then can perform some task based on that fact.
if [ $SHELL == /bin/tcsh ]; then
    echo tcsh
elif [ $SHELL == /bin/bash ]; then
    echo bash
else
    echo shell not found
fi


#!/bin/bash

#setup.sh
#Written By Alex Tong January 28, 2015
#This script runs the config package to set up a remote linux machine

echo "Running ssh-config.sh"
./ssh-config.sh
echo "copying .vimrc"
cp .vimrc ~
echo "setup complete"


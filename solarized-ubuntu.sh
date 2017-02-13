#!/bin/bash
#
# This script was tested on ubuntu 16.04 (prodigy) Feb 17
#
# http://www.webupd8.org/2011/04/solarized-must-have-color-paletter-for.html

wget --no-check-certificate https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-dark
mv dircolos.ansi-dark ~/.dircolors
eval `dircolors ~/.dircolors`

git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized
./set_dark.sh

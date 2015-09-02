#!/bin/bash
# Installation of sublime along with its lint and other tools
# 
# we don't have ws-env.sh available to us at bootstrap time
# set -eo pipefail && . `dirname $0`/ws-env.sh && SCRIPTNAME=$(basename $0)
set -eo pipefail && SCRIPTNAME=$(basename $0)

# over kill for a single flag to debug, but good practice
OPTIND=1

while getopts "hd" opt
do
case "$opt" in
	h)
		echo $0 "flags: -d debug, -h help"
		exit 0
		;;
    d)
		# -x is x-ray or detailed trace, -v is verbose, trap DEBUG single steps
		set -vx -o functrace
		trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG
        debugging=true
		;;
	esac
done
debugging=${debugging:=false}

set -u

verlte() {
        [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

verlt() {
        [ "$1" = "$2" ] && return 1 || verlte $1 $2
}

if verlt $(nodejs -v) v0.10
then
    $debugging && echo $SCRIPTNAME: installing later node
    sudo apt-get install python-software-properties
    # remove first so we don't duplicae over and over
    sudo add-apt-repository -r -y  ppa:chris-lea/node.js
    sudo apt-add-repository -y ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install -y nodejs
fi

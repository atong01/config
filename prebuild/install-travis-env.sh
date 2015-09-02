#!/bin/bash
## Installation npm suitable for m2 on Ubuntu earlier than 14.04
## which we can use to install locally something that looks like the
## travis-ci.com build environment which is good for DEBUGGING
## 
##
## These are the minimums to run m2 build
## In this case we need node > 0.10 which gives us a good npm
## Also need git of at least 1.8
##
## @author Rich Tong
## @returns 0 on success
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
        DEBUGGING=true
		;;
	esac
done
DEBUGGING=${DEBUGGING:=false}

set -u

verlte() {
        [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

function verlt() {
        [ "$1" = "$2" ] && return 1 || verlte "$1" "$2"
}

##install
##@param $1 package name
##@param $2 ppa repository
function install() {
        $DEBUGGING && echo $SCRIPTNAME: installing $1 from $2
        sudo apt-get install python-software-properties
        sudo add-apt-repository -r -y  "$2"
        sudo add-apt-repository -y "$2"
        sudo apt-get update
        sudo apt-get install -y "$1"
}

$DEBUGGING && echo $SCRIPTNAME: testing `nodejs -v`
# node sticks a 'v' in front so add a v to version 0.10
if verlt $(nodejs -v) v0.10
then
    install "nodejs" "ppa:chris-lea/node.js"
fi

if verlt $(git version | cut -f3 -d' ') 1.9
then
    install "git" "ppa:git-core/ppa"
fi

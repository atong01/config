#!/bin/bash
# 
## Install Ubnutn Logical Volume Manager
##
## This is a lightweight way to get file system snapshots on a local machine
## before we make the jump to docker
##
## @author Rich
#
# set -eo pipefail && . `dirname $0`/ws-env.sh && SCRIPTNAME=$(basename $0)
set -eo pipefail && SCRIPTNAME=$(basename $0)

OPTIND=1
while getopts "hd" opt
do
case "$opt" in
	h)
		echo $0 "flags: -d debug" 
		exit 0
		;;
    	d)
		# -x is x-ray or detailed trace, -v is verbose, trap DEBUG single steps
		set -vx -o functrace
		trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG
		;;
	esac
done

set -u

command -v gparted || sudo apt-get install -y gparted

sudo gparted


#!/bin/bash
## verify docker
## @author rich
## @function verify-docker
## @return o if successful
#
# Run after docker installed as a test
# set -eo pipefail && . `dirname $0`/ws-env.sh && SCRIPTNAME=$(basename $0)
# no ws-env.sh available
set -eo pipefail && SCRIPTNAME=$(basename $0)

# over kill for a single flag to debug, but good practice
OPTIND=1
while getopts "hd" opt
do
	case "$opt" in
	h)
		echo $0 "flags: -d debug -f git-lfs file" 
		exit 0
		;;
	d)
		# -x is x-ray or detailed trace, -v is verbose, trap DEBUG single steps
		set -vx -o functrace
		trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG
		;;
	esac
done
WS_DIR=${WS_DIR:-"$HOME/ws"}

# now we can check for unbound variables
set -u

if ! docker run hello-world
then
    echo $SCRIPTNAME: docker did not install correctly
    exit 1
fi

#!/bin/bash
#
# The development tools rich uses
#
set -eo pipefail && . `dirname $0`/ws-env.sh && SCRIPTNAME=$(basename $0)

# over kill for a single flag to debug, but good practice
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
# The default is ws and others, you can either set in flags
# Or as shell variables exported
# For whatever reason you must use $HOME here and not ~ even though
# test works in interactive bash but won't work in a script

# now we can check for unbound variables
set -u

PACKAGES=""

# packages needed for personal debugging, do not use steam becaue it is
# interactive installed

PACKAGES+="chromium-browser "

PACKAGES+="meld "

# packages for 1password, but remember you also need to allow local file access
# for this to work in the browser
PACKAGES+="nautilus-dropbox "

# Compiz Grid allows keyboard shortcuts to move windows aroudn
PACKAGES+="compizconfig-settings-manager "

git config --global diff.tool meld
git config --global merge.tool meld

sudo apt-get install -y $PACKAGES

#!/bin/bash
# 
# Installs the proprietary nVidia drivers
# Installs steam to download test game applications
#

# Standard names are not available
# set -eo pipefail && . "$(dirname "$0")/ws-env.sh" && SCRIPTNAME="$(basename "$0")" 
set -eo pipefail && SCRIPTNAME="$(basename "$0")" 

# fail on unbound variables
set -u


# over kill for a single flag to debug, but good practice
OPTIND=1

# Default is the latest
nvidia_version=352
while getopts "hdv" opt
do
case "$opt" in
	h)
		echo $0 "flags: -d debug, -v version"
		exit 0
		;;
    d)
		# -x is x-ray or detailed trace, -v is verbose, trap DEBUG single steps
		set -vx -o functrace
		trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG
		;;
	v)
		nvidia_version="$OPTARG"
		;;
	esac
done


if ! lspci | grep "VGA.*NVIDIA"
then
	echo $SCRIPTNAME: No NVIDIA adapter found with lspci >&2
	exit 0
fi

if ! ls /etc/apt/sources.list.d/xorg-edgers*
then
	sudo add-apt-repository ppa:xorg-edgers/ppa
	sudo apt-get update
fi

# http://askubuntu.com/questions/319307/reliably-check-if-a-package-is-installed-or-not
if dpkg-query -W -f'${Status}' 'nvidia-*' | grep -q "ok installed"
then
    echo $SCRIPTNAME: Warning nvidia driver already installed 
    echo You should sudo apt-get remove --purge nvidia-*
    echo and then reboot and run this script
else
    echo $SCRIPTNAME: Install nvidia version $nvidia_version
    sudo apt-get install -y nvidia-$nvidia_version
fi

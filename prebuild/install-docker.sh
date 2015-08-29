#!/bin/bash
## install docker
## @author rich
## @function install-docker
## @return o if successful
## Doxygen documentation needs two hastags
## http://rickfoosusa.blogspot.com/2011/08/howto-have-doxygen-support-bash-script.html
# set -eo pipefail && . `dirname $0`/ws-env.sh && SCRIPTNAME=$(basename $0)
# no ws-env.sh available
set -eo pipefail && SCRIPTNAME=$(basename $0)


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

if  ! command -v virt-what
then
    sudo apt-get install -y virt-what
fi

if [[ -n $(sudo virt-what) ]]
then
    echo $SCRIPTNAME: cannot install docker in a virtual machine
fi

if ! command -v docker
then
    wget -qO- https://get.docker.com/ | sh
fi 

# If a non-root users, add to the docker group
sudo usermod -aG docker $USER

# https://github.com/docker/docker/issues/12002
# need to ignore error if started already
if  sudo service docker status | fgrep stop
then
	# note that start returns 1 if it is already started
	sudo service docker start 
fi

echo $SCRIPTNAME: docker requires logout to work properly

if ! docker run hello-world
then
    echo $SCRIPTNAME: docker did not install correctl
    exit 1
fi

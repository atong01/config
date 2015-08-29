#!/bin/bash
## installs surround.io lfs in prebuild -*- shell-script -*-
## @author rich
## @function install-lfs
## @return o if successful
## Doxygen documentation needs two hastags
## http://rickfoosusa.blogspot.com/2011/08/howto-have-doxygen-support-bash-script.html
# set -eo pipefail && . `dirname $0`/ws-env.sh && SCRIPTNAME=$(basename $0)
# no ws-env.sh available
set -eo pipefail && SCRIPTNAME=$(basename $0)

# over kill for a single flag to debug, but good practice
OPTIND=1
while getopts "hdf:w:" opt
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
    f) 
        gitlfsfile="$OPTARG"
        ;;
    w) 
        WS_DIR="$OPTARG"
	esac
done
gitlfsfile=${gitlfsfile:-"https://github.com/github/git-lfs/releases/download/v0.5.4/git-lfs-linux-amd64-0.5.4.tar.gz"}
WS_DIR=${WS_DIR:-"$HOME/ws"}

# now we can check for unbound variables
set -u


echo $SCRIPTNAME: Warning, we are tied to installing $gitlfsfile
mkdir -p ~/Downloads/git-lfs-install
pushd ~/Downloads/git-lfs-install
downloaded=$(basename $gitlfsfile)
if [ ! -e $downloaded ]
then
    wget "$gitlfsfile" 
    tar xf $downloaded --strip-components 1
fi
echo $SCRIPTNAME: ignoring buggy first line of install.sh
tail -n +2 install.sh | sudo bash
popd

echo $SCRIPTNAME: Cloning and install surround.io git lfs repo
pushd "$WS_DIR/git"
if [ ! -e lfs ]
then
    git clone git@github.com:surround-io/lfs
    cd lfs
    git lfs track "*.mp4" "*.jpg" "*.ts" "*.png"

fi
popd


#!/bin/bash
#
# This script is designed to run *before* you have the git/source 
# so it does all the precursors before installation
# Rich created this because he is building so many many machines
# 
# Defaults to using the development account surround against test@surround.io
#
# we don't have ws-env.sh available to us at bootstrap time
# set -eo pipefail && . `dirname $0`/ws-env.sh && SCRIPTNAME=$(basename $0)
set -eo pipefail && SCRIPTNAME=$(basename $0)


# over kill for a single flag to debug, but good practice
OPTIND=1
while getopts "xhdw:u:e:s:w:" opt
do
case "$opt" in
	h)
		echo $0 "flags: -d debug, -u <user> git name, -e <email> git email -s ssh dir, -w wsdir"
		exit 0
		;;
    d)
		# -x is x-ray or detailed trace, -v is verbose, trap DEBUG single steps
		set -vx -o functrace
		trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG
		;;
	u)
		GIT_USER="$OPTARG"
		;;
	e)
		GIT_EMAIL="$OPTARG"
		;;
	w)
		WS_DIR="$OPTARG"
		;;
	s)
		SSH_DIR="$OPTARG"
        ;;
    x)
        NO_PASSWORD=false
	esac
done
# The default is ws and others, you can either set in flags
# Or as shell variables exported
# For whatever reason you must use $HOME here and not ~ even though
# test works in interactive bash but won't work in a script
WS_DIR=${WS_DIR:-"$HOME/ws"}
SOURCE_DIR="$WS_DIR/git/source"
GIT_USER=${GIT_USER:-"Rich Tong"}
GIT_EMAIL=${GIT_EMAIL:-"rich@surround.io"}
SCRIPTDIR=${SCRIPTDIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}
SSH_DIR=${SSH_DIR:-"$SCRIPTDIR/ssh"}
NO_PASSWORD=${NO_PASSWORD:-true}

# now we can check for unbound variables
set -u

echo $SCRIPTNAME: creating surround.io in $WS_DIR for user $GIT_USER and email $GIT_EMAIL
mkdir -p "$WS_DIR"
if [ ! -d "$WS_DIR" ]
then
	echo Could not install into $WS_DIR
	exit 1
fi

echo $0: trying to find ssh folder that you should have previously copied
# bug here I can't figure out this fails even if a directory is there??!
if [ -d "$SSH_DIR" ]
then
	mkdir -p "$HOME/.ssh"
	# On the quoting, remember, you want the asterick * to be outside
	# the quote so it wildcards, so "$HOME/.ssh/*" does not work
	# but "$HOME"/.ssh/* does
	cp "$SSH_DIR"/* "$HOME/.ssh" || echo $0: files already in .ssh
	chmod 700 "$HOME/.ssh"
    # 600 is needed so credentials/restore-keys.py works
	chmod 600 "$HOME/.ssh/"*
	chmod 600 "$HOME/.ssh/"known_hosts*
else
	echo $0: no $SSH_DIR found, assuming .ssh is set correctly
fi

# Because I couldn't figure out how to get the stderr out wtih 2|
# because ssh to git hub generates an error if you try to run
# a command with it
# Note that ssh returns error always because github prevents ssh
# interactive session even if it is keys are ok
TEMP=$(mktemp)
ssh -T git@github.com |& tee "$TEMP" || true
if ! fgrep "successfully authenticated" "$TEMP"
then
	echo $SCRIPTNAME: bad ssh keys or no internet could not get into git hub
	rm "$TEMP"
	exit 2
fi
rm "$TEMP"

# the first number indicates priority
SUDOERS="/etc/sudoers.d/10-$USER"
if [[ "$NO_PASSWORD" = true  && (! -e "$SUDOERS") ]]
then
    sudo tee "$SUDOERS" <<<"$USER ALL=(ALL:ALL) NOPASSWD:ALL" 
    sudo chmod 440 "$SUDOERS"
fi

# Speed up for apt-get by preferring IPv4
# Don't have everything go to ipv4 as this doesn, but instead just for apt
# if ! grep "^precedence ::ffff:0:0/96.*100$" /etc/gai.conf
# then
#     sudo tee -a /etc/gai.conf <<<"precedence ::ffff:0:0/96   100"
# fi

# Per http://unix.stackexchange.com/questions/9940/convince-apt-get-not-to-use-ipv6-method
if ! sudo touch /etc/apt/apt.conf.d/99force-ipv4 
then 
    echo $SCRIPTNAME: Could not create 99force-ipv4
elif ! grep "^Acquire::ForceIPv4" /etc/apt/apt.conf.d/99force-ipv4
then
        sudo tee -a /etc/apt/apt.conf.d/99force-ipv4 <<<'Acquire::ForceIPv4 "true";'
fi 


sudo apt-get update
sudo apt-get upgrade

# this makes sure npm is up to date so run it early
# which means that git and npm work correctly at least
# make sure that we are at least at the travis package level 
bash "$SCRIPTDIR/install-travis-env.sh"


command -v git || sudo apt-get install -y git 
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
# Git is changing its default and this gets rid of warning messages

verlte() {
	[ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}
verlt() {
	[ "$1" = "$2" ] && return 1 || verlte "$1" "$2" ]
}
vergte() {
	[ "$1" = "$(echo -e "$1\n$2" | sort -V | tail -n1)" ]
}

# There is no simple in git 1.7
if verlt $(git version | cut -f3 -d' ') 1.8
then
	git config --global push.default simple
fi

mkdir -p "$WS_DIR"/git

# Pushes things assuming your git directory is $SCRIPTDIR/git a la Sam's convention
function git_install_or_update() {
	if [ -z "$1" ]
	then
		return 1
	elif cd "$WS_DIR/git/$1"
	then
		if ! git pull
		then
			echo $0 could not git pull $WS_DIR/git/$1
			return $?
		fi
	elif ! cd "$WS_DIR/git"
	then
		echo $0: No $WS_DIR/git found
		return $?
	elif ! git clone git@github.com:surround-io/$1
	then
		echo $0 could not git clone $WS_DIR/git
		return $?
	fi

	echo $0: get submodules for $1
	if ! cd "$WS_DIR/git/$1"
	then
		echo $0 could not clone into $1	
		return $?
	fi
# In latest m2, we should cache this instead
#	elif ! git submodule sync --recursive
#	then
#		echo $0 could not git submodule sync
#		return $?
#	elif ! git submodule update --init --recursive
#	then
#		echo $0 could not git submodule update
#		return $?
#	fi
	return 0
}

# download the repo
git_install_or_update source

# Get the AWS credentials into place
bash "$SCRIPTDIR/install-aws.sh"

# We also use the save and restore key if you have it already
if [ -e "$WS_DIR/git/source/credentials/$GIT_USER" ]
then
    pushd "$WS_DIR/git/source/credentials"
    ./restore-keyset.py -f
    popd
fi

# now get the environment right
if ! grep "added by $SCRIPTNAME" ~/.bashrc
then
    # A conflict here, bash here documents expect to see real tabs
    # They do not suppress spaces! # http://tldp.org/LDP/abs/html/here-docs.html
    # were inserted with CTRL-V and then a Tab
    echo "# added by $SCRIPTNAME on $(date)" >> ~/.bashrc
    echo "source $SOURCE_DIR/bin/export-env" >> ~/.bashrc
    echo 'export rpis=$(arp -n | grep b8 | cut -f1 -d" ")' >> ~/.bashrc


fi

# specific things for rich
if [[ "$USER" = rich ]]
then
    # These are now done by the python script
    # echo "export VISUAL=$(command -v vi)" >> ~/.bashrc
    # cp "$SCRIPTDIR/vimrc" ~/.vimrc
    # which needs npm for linters and things
    command -v npm || sudo apt-get install -y npm
    python "$SCRIPTDIR/install-vim.py"

    # @rich doesn't use sublime much but customzie anyway
    # deal with potential ENOSPC errors due to sublime
    bash "$SCRIPTDIR/install-sublime.sh"
    if ! grep "^fs.inotify.max_user_watches" /etc/sysctl.conf
    then
        echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
    fi

fi


# http://stackoverflow.com/questions/3231804/in-bash-how-to-add-are-you-sure-y-n-to-any-command-or-alias
# This is only for M1 so comment out
# read -r -p "$SCRIPTNAME: Are you using wlan0 for public network [y/N]?" response
# response=${response,,} # to lower case
# if [[ "$response" =~ ^(yes|y)$ ]]
# then
# 	cp "$SOURCE_DIR/configs/ws-vars-wlan0-public.sh" "$WS_DIR/ws-vars.sh"
# fi


# Device drivers
bash "$SCRIPTDIR/install-nvidia.sh"
bash "$SCRIPTDIR/install-dwa182.sh"

bash "$SCRIPTDIR/install-dev-packages.sh"

read -r -p "$SCRIPTNAME: Reboot now or source ~/.bashrc and you are ready to build"

#!/bin/bash
# install the Amazon AWS components

# Use standard build environment layout
set -e && . "$(dirname "$0")/ws-env.sh" && SCRIPTNAME="$(basename "$0")"

# get command line options
OPTIND=1
while getopts "hdi:" opt; do
case "$opt" in
	h)
		echo $SCRIPTNAME "flags: -d : debugi, -a awskeyfiles"
		exit 0
		;;
    d)
		set -vx -o functrace
		trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG
		;;
    a)
        awsfiles="$OPTARG"   
        ;;
	esac
done

awsfiles=${awsfiles:-$HOME/prebuild}


# For travis using 12.04, need different install
# http://stackoverflow.com/questions/4023830/bash-how-compare-two-strings-in-version-format
verlte() {
	[ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}
verlt() {
	[ "$1" = "$2" ] && return 1 || verlte $1 $2 ]
}


# 14.04 had a simpler installer
if verlt "$(lsb-release -sr)" 14.04
then
	sudo apt-get install -y python-pip
	sudo pip install awscli
else
	sudo apt-get install -y awscli
fi

# http://stackoverflow.com/questions/24542934/automating-bat-file-to-configure-aws-s3
# There are other ways to do this
if [ ! -e ~/.aws/config ]
then
    echo $SCRIPTNAME: creating AWS configuration file
    mkdir -p ~/.aws
    tee ~/.aws/config <<-EOF
		[profile surroundio-build]
		aws_access_key_id = $(cat $awsfiles/ssh/aws-access-key-id)
		aws_secret_access_key = $(cat $awsfiles/ssh/aws-access-key)
		output = json
		region = us-west-2
	EOF
    # 600 is needed so credentials/restore-keys.py works
    chmod 600 ~/.aws/config
fi
# Sam's way of doing this same configuration using a deployment key kept in AWS
# Eventually we will also do it this way, but need a bootstrap set of keys first
# aws --profile surroundio-build s3 cp s3://surroundio-deploy-keys/iam/surroundio-deploy.aws-configure.stdin /tmp/cfg.$$.tmp
# aws configure --profile surroundio-deploy < /tmp/cfg.$$.tmp > /dev/null
# rm /tmp/cfg.$$.tmp

if ! aws --profile surroundio-build s3 cp s3://surroundio-build-artifacts/rpi-img/2014-09-09-wheezy-raspbian.tar.gz.sha1.txt /dev/stdout
then
    echo SCRIPTNAME: Could not get s3://surroundio-build-artifacts/rpi-img/2014-09-09-wheezy-raspbian.tar.gz.sha1.txt
    exit 1
>&2 
fi


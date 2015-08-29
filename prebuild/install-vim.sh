#!/bin/bash
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
		;;
	esac
done

set -u

# Need full vim for packages
sudo apt-get install -y vim


# http://eslint.org/docs/user-guide/command-line-interface.html
sudo npm install -g eslint


# https://github.com/scrooloose/syntastic for multiple syntax checkers
if [ ! -e ~/.vim/autoload/pathogen.vim ]
then
    mkdir -p ~/.vim/autoload ~/.vim/bundle && \
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
fi

if ! grep pathogen ~/.vimrc 
then
    cat >>~/.vimrc <<EOF
" inserted by $SCRIPTNAME on $(date)
execute pathogen#infect()
syntax on
filetype plugin indent on
EOF
fi

if [ ! -e ~/.vim/bundle/syntastic ]
then
    cd ~/.vim/bundle && \
    git clone https://github.com/scrooloose/syntastic.git
fi

if ! grep syntastic ~/.vimrc
then
    cat >> ~/.vimrc <<EOF
" Installed by $0 on `date`
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
EOF
fi

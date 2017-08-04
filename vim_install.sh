# vim_install.sh
# Install pathogen and vim plugins
# TODO: install as submodules
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

cd ~/.vim/bundle && git clone https://github.com/tpope/vim-sensible.git

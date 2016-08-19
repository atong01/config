
"call plug#begin('~/.vim/plugged')
"
"Plug 'morhetz/gruvbox'
"
"call plug#end()
"

execute pathogen#infect()

"colorscheme gruvbox
"

syntax enable
set background=dark
colorscheme solarized

silent! set colorcolumn=80
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set ruler
set cursorline

"paste from clipboard stuff
set pastetoggle=<F10>
inoremap <C-v> <F10><C-r>+<F10>

"tabsetup
let mapleader=","
map <leader>tt :tabnew<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>tn :tabnext<cr>
map <leader>tp :tabprevious<cr>


set scrolloff=5 "keeps 5 lines above and below cursor
set ai          "set auto indent
set si          "set smart indent
set nu          "set line numbers

" comments
map ,# :s/^/#/<CR>
map ,> :s/^/> /<CR>
map ," :s/^/\"/<CR>
map ,% :s/^/%/<CR>
map ,! :s/^/!/<CR>
map ,; :s/^/;/<CR>
map ,- :s/^/--/<CR>
" wrapping comments
map ,( :s/^\(.*\)$/\(\* \1 \*\)/<CR>
map ,< :s/^\(.*\)$/<!-- \1 -->/<CR>
map ,d :s/^\([/(]\*\\|<!--\) \(.*\) \(\*[/)]\\|-->\)$/\2/<CR>

function! Komment()
  if getline(".") =~ '\/\*'
    let hls=@/
    s/^\/\*//
    s/*\/$//
    let @/=hls
  else
    let hls=@/
    s/^/\/*/
    s/$/*\//
    let @/=hls
  endif
endfunction
map <leader>k :call Komment()<CR>

imap jj <esc>
imap jk <esc>
imap kk <esc>

set makeprg=./compile

syntax on
filetype plugin on
filetype indent on

" Processing
"au BufRead,BufNewFile *.pde setf processing
" 
" hardcore hax
":command! P :! processing-java --sketch=$PWD/ --output=temp --run --force
:command! PP :! processing-java --sketch=$PWD/ --output=temp --force --run
"autocmd BufNewFile,BufRead *.pde set makeprg=mkdir\ -p\ ./output\ &&\ processing-java\ --sketch=\"`pwd`\"\ --output=\"`pwd`\"/output\ --run\ --force
nnoremap <Tab> :w<bar>:make<bar><CR>
nnoremap ` :w<bar>:!python %<CR>

autocmd FileType python map <buffer> <C-G> :!python % <CR>


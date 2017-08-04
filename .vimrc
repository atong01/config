
syntax enable
set background=dark
"autocmd FileType python map <buffer> <C-G> :!python % <CR>

filetype plugin on
filetype indent on
"silent! set colorcolumn=80
let mapleader=","
set expandtab
set smarttab
set shiftwidth=2
set tabstop=2
set softtabstop=2

set wildmenu
set lazyredraw
set showmatch
set incsearch
set hlsearch
nnoremap <leader><space> :nohlsearch<CR>

set ruler
set cursorline

"paste from clipboard stuff
set pastetoggle=<F10>
inoremap <C-v> <F10><C-r>+<F10>

"tabsetup
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

" Processing
"au BufRead,BufNewFile *.pde setf processing
" 
" hardcore hax
":command! P :! processing-java --sketch=$PWD/ --output=temp --run --force
":command! PP :! processing-java --sketch=$PWD/ --output=temp --force --run
"autocmd BufNewFile,BufRead *.pde set makeprg=mkdir\ -p\ ./output\ &&\ processing-java\ --sketch=\"`pwd`\"\ --output=\"`pwd`\"/output\ --run\ --force
"

"Compile HAX
nnoremap <Tab> :w<bar>:make<bar><CR>
nnoremap ` :w<bar>:!wvrun python %<CR>

nnoremap <leader>ev :vsp $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

call pathogen#infect()
"call pathogen#runtime_append_all_bundles()

augroup configgroup
    autocmd!
    autocmd VimEnter * highlight clear SignColumn
"    autocmd BufWritePre *.php,*.py,*.js,*.txt,*.hs,*.java,*.md
"                \:call <SID>StripTrailingWhitespaces()
    autocmd FileType java setlocal noexpandtab
    autocmd FileType java setlocal list
    autocmd FileType java setlocal listchars=tab:+\ ,eol:-
    autocmd FileType java setlocal formatprg=par\ -w80\ -T4
    autocmd FileType php setlocal expandtab
    autocmd FileType php setlocal list
    autocmd FileType php setlocal listchars=tab:+\ ,eol:-
    autocmd FileType php setlocal formatprg=par\ -w80\ -T4
    autocmd FileType ruby setlocal tabstop=2
    autocmd FileType ruby setlocal shiftwidth=2
    autocmd FileType ruby setlocal softtabstop=2
    autocmd FileType ruby setlocal commentstring=#\ %s
    autocmd FileType python setlocal commentstring=#\ %s
    autocmd FileType python setlocal shiftwidth=2
    autocmd FileType python setlocal tabstop=2
    autocmd FileType python setlocal softtabstop=2
    autocmd BufEnter *.cls setlocal filetype=java
    autocmd BufEnter *.zsh-theme setlocal filetype=zsh
    autocmd BufEnter Makefile setlocal noexpandtab
    autocmd BufEnter *.sh setlocal tabstop=2
    autocmd BufEnter *.sh setlocal shiftwidth=2
    autocmd BufEnter *.sh setlocal softtabstop=2
augroup END

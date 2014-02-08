set nocompatible

syntax on
filetype plugin on

" Highlight all matches of searched pattern. To temporarily turn this off you
" can use :noh[lsearch]. It will be automatically turned back on the next
" search.
set hlsearch

" Move to searched text as you type.
set incsearch

" Minimal number of lines to be shown below and above current cursor position.
set scrolloff=2

" Show line and column number of current cursor position.
set ruler

set autoindent
set smartindent

" Show commands, as they are constructed, in the status line.
set showcmd

" Don't insert two spaces after '.', '?' and '!' when using join command.
set nojoinspaces

" Assume that terminal has dark background.
set background=dark

" GUI colours
highlight Normal guibg=black
highlight Normal guifg=green

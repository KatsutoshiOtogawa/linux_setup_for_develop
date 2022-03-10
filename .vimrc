

set number
set showmode
set showcmd
set ruler
set autoindent
set smartindent

autocmd BufRead,BufNewFile *.{js,mjs,ts,py,php,cc,cs,java,json} set expandtab
autocmd BufRead,BufNewFile *.{py,php,cc,cs,java,go,json} set tabstop=4
autocmd BufRead,BufNewFile *.{py,php,cc,cs,java,go,json} set shiftwidth=4

" javascript setting
autocmd BufRead,BufNewFile *.{js,mjs,ts,yaml,yml,html,css,scss} set tabstop=2
autocmd BufRead,BufNewFile *.{js,mjs,ts,yaml,yml,html,css,scss} set shiftwidth=2

" install vim plugin list
" :PlugInstall -> install plugin 
" :PlugUpdate -> install update
call plug#begin()

Plug 'tpope/vim-surround'

Plug 'tpope/vim-fugitive'

Plug 'scrooloose/nerdtree'

Plug 'tpope/vim-repeat'

Plug 'tpope/vim-commentary'

Plug 'pangloss/vim-javascript'

Plug 'majutsushi/tagbar'

Plug 'mattn/emmet-vim'

call plug#end()


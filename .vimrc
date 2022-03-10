"" setting for vim.

"" installed vim plugins.

" [vim plug](https://github.com/junegunn/vim-plug)
" install vim plugin list
" :PlugInstall -> install plugin 
" :PlugUpdate -> install update
call plug#begin()

" [vim-surround](https://github.com/tpope/vim-surround)
" visual mode selecting character, surround 
" ex) select 'awesome' and type 'S{' write '{awesome}'.
  Plug 'tpope/vim-surround'

" [vim-fugitive](https://github.com/tpope/vim-fugitive)
" visual mode selecting character, surround 
" ex) select 'awesome' and type 'S{' write '{awesome}'.
  Plug 'tpope/vim-fugitive'

" [vim-gitgutter](https://github.com/airblade/vim-gitgutter)
" visual mode selecting character, surround 
" ex) select 'awesome' and type 'S{' write '{awesome}'.
  Plug 'airblade/vim-gitgutter'

" [nerdtree](https://github.com/scrooloose/nerdtree)
" [refrence](https://qiita.com/zwirky/items/0209579a635b4f9c95ee)
" show directory tree.
" ex)Ex command type 'NERDTreeToggle'
  Plug 'scrooloose/nerdtree'

" [vim-reapeat](https://github.com/tpope/vim-repeat)
" extension for . command plugin.
" ex) select 'awesome' and type 'S{' write '{awesome}'.
  Plug 'tpope/vim-repeat'

" [vim-commentary](https://github.com/tpope/vim-commentary)
" extension for . command plugin.
" ex Normalmode ) gcc -> comment editting row.
" ex Visual mode) gc -> selecting row commented
" if you comment customize file, set below setting.
" autocmd FileType apache setlocal commentstring=#\ %s
  Plug 'tpope/vim-commentary'

" [vim-javascript](https://github.com/pangloss/vim-javascript)
" extension for . command plugin.
" ex) select 'awesome' and type 'S{' write '{awesome}'.
  Plug 'pangloss/vim-javascript'

" [tagbar](https://github.com/majutushi/tagbar)
" extension for . command plugin.
" ex) select 'awesome' and type 'S{' write '{awesome}'.
  Plug 'majutsushi/tagbar'

" [emmet-vim](https://github.com/mattn/emmet-vim)
" extension for . command plugin.
" ex) select 'awesome' and type 'S{' write '{awesome}'.
  Plug 'mattn/emmet-vim'

call plug#end()

"" default settings.

set number
set list
set hlsearch
set showmode
set showcmd
set ruler
set autoindent
set smartindent

" open source tree and move to editting window
autocmd BufRead,BufNewFile * NERDTreeToggle | wincmd w

" set *.sh file highlight for coding.
autocmd BufRead,BufNewFile *.sh set filetype=sh

" expand tab files.
autocmd BufRead,BufNewFile *.{sh,ps1,psd1,psm1,js,mjs,ts,py,php,cc,cs,java,json,md} set expandtab

" general programing files
autocmd BufRead,BufNewFile *.{sh,ps1,psd1,psm1,py,php,cc,cs,java,go} set tabstop=4
autocmd BufRead,BufNewFile *.{sh,ps1,psd1,psm1,py,php,cc,cs,java,go} set shiftwidth=4

" javascript and browser setting
autocmd BufRead,BufNewFile *.{js,mjs,ts,json,yaml,yml,html,css,scss} set tabstop=2
autocmd BufRead,BufNewFile *.{js,mjs,ts,json,yaml,yml,html,css,scss} set shiftwidth=2

" text files
autocmd BufRead,BufNewFile *.{md} set tabstop=2
autocmd BufRead,BufNewFile *.{md} set shiftwidth=2

" tsv
autocmd BufRead,BufNewFile *.{tsv} set tabstop=2
autocmd BufRead,BufNewFile *.{tsv} set shiftwidth=2


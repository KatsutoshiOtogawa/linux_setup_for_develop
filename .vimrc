"" setting for vim.

" read plugin
source ~/vim/plugin.vimrc

"" default settings.

set number
set list
set hlsearch
set showmode
set showcmd
set clipboard+=unnamed
set ruler
set autoindent
set smartindent

" [autocmd explain](https://maku77.github.io/vim/settings/autocmd.html)
" open source tree and move to editting window
" autocmd TabNew,VimEnter * NERDTreeToggle | wincmd l
" 隠しファイルを表示
let NERDTreeShowHidden = 1
" カレントディレクトリの場合は２中に開いてしまうので、閉じる。
" autocmd TabNew,VimEnter . NERDTreeToggle | wincmd l

" set *.sh file highlight for coding.
autocmd BufRead,BufNewFile *.sh set filetype=sh
autocmd BufNewFile  *.sh  0r ~/vim/bash/skeleton.sh
" autocmd BufNewFile  *.sh  0r ~/vim/bash/skeleton.sh | %s/command_name//g

" expand tab files.
autocmd BufRead,BufNewFile *.{sh,ps1,psd1,psm1,js,mjs,ts,py,php,cc,cs,java,json,yaml,yml,html,css,scss,md} set expandtab

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


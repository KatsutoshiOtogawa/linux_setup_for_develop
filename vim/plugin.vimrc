
"" installed vim plugins.
" [vim plug](https://github.com/junegunn/vim-plug)
" install vim plugin list
" :PlugInstall -> install plugin
" :PlugUpdate -> install update
call plug#begin()

" [vim-surround](https://github.com/tpope/vim-surround)
" visual mode selecting character, surround
" ex) select 'awesome' and type 'S{' write '{awesome}'.
" ex) select 'hello world' and type 'S<div>' write '<div>hello world</div>'
" ex) internal '<p>Why! Why!</p>' and type 'ds<p>' write 'Why! Why!'
" ex) internal '<h2>No! No!</h2>' and type 'cs<h2><h3>' write '<h3>No! No!</h3>'
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
" if you want to reload dispaley, type 'R'
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

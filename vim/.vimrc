" Automatic install if not yet installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent!curl - fLo ~/.vim/autoload / plug.vim--create - dirs
\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall--sync | source $MYVIMRC
endif
" Vim-Plug
call plug#begin()
" Initialize plugin system"
Plug 'vim-airline/vim-airline'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline-themes'
Plug 'phanviet/vim-monokai-pro'
Plug 'joshdick/onedark.vim', { 'as': 'onedark' }
" Github marks in the gutter
Plug 'airblade/vim-gitgutter'
" Git support in vim
Plug 'tpope/vim-fugitive'
" TOML support for vim
Plug 'cespare/vim-toml'
call plug#end()

syntax on
set number

" Reasonable indentations
set expandtab tabstop=4 shiftwidth=4 softtabstop=4

nnoremap < leader > n : NERDTreeFocus<CR>
nnoremap < C - n > : NERDTree<CR>
nnoremap < C - t > : NERDTreeToggle<CR>
nnoremap < C - f > : NERDTreeFind<CR>

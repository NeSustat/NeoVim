" --- Общие настройки ---
syntax on
set number
set tabstop=4
set shiftwidth=4
set expandtab
set encoding=utf-8
set hidden
set updatetime=300
set signcolumn=yes

let mapleader = "\\"

" --- Плагины ---
call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'joshdick/onedark.vim'

call plug#end()

" --- Цветовая схема ---
colorscheme onedark

" --- airline ---
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#fnamemod = ':t'

" --- Открывать сначала терминал, потом файл (если есть) ---
autocmd VimEnter * call SetupTabs()

function! SetupTabs()
  if argc() > 0
    let l:file = argv(0)
    args []
    tabnew | terminal
    tabnew | execute 'edit' fnameescape(l:file)
    " Закрываем первую вкладку (ненужную с auto-открытым файлом)
    silent! tabclose 1
  else
    tabnew | terminal
    tabnew | enew
    silent! tabclose 1
  endif
endfunction

" --- Убиваем все окна по :q или :wq ---
command! Q tabdo q! | redraw!
command! WQ wall | tabdo q! | redraw!

cnoreabbrev q Q
cnoreabbrev wq WQ

" --- Ctrl+Tab: переходит в следующий таб из любого режима (в том числе терминала) ---
tnoremap <A-BS> <C-\><C-n>:tabnext<CR>
nnoremap <A-BS> :tabnext<CR>
inoremap <A-BS> <Esc>:tabnext<CR>
vnoremap <A-BS> <Esc>:tabnext<CR>

" --- Ctrl+Shift+Tab: переход в предыдущий таб
tnoremap <A-SPACE> <C-\><C-n>:tabprevious<CR>
nnoremap <A-SPACE> :tabprevious<CR>
inoremap <A-SPACE> <Esc>:tabprevious<CR>
vnoremap <A-SPACE> <Esc>:tabprevious<CR>


" --- Терминал: выход по <Esc> ---
tnoremap <Esc> <C-\><C-n>

" Показывать airline даже в терминале
let g:airline#extensions#term#enabled = 1

" пока не знаю, но надо
set laststatus=3

" надо чтобы исправить ошибку с двумя airline
autocmd BufEnter * if exists('*AirlineRefresh') | call airline#extensions#tabline#init() | call AirlineRefresh() | endif


" --- Общие настройки ---
syntax on
set relativenumber     " относительные для остальных
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
" цветовые схемы
Plug 'joshdick/onedark.vim'
Plug 'bcicen/vim-vice'

call plug#end()

" --- Настройка Coc ---
"  принять подсказку
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm() : "\<CR>"


" --- Цветовая схема ---
"colorscheme onedark
colorscheme vice

" --- airline ---
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#fnamemod = ':t'

" настройка табов
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#tab_nr_type = 0

let g:airline#extensions#tabline#formatter = 'custom'

" надо чтобы исправить ошибку с двумя airline
autocmd BufEnter * if exists('*AirlineRefresh') | call airline#extensions#tabline#init() | call AirlineRefresh() | endif

" настройка нижней полоски
" Кастомизация правой части airline
function! MyCleanAirlineRight()
  let l:line = line('.')
  let l:total = line('$')
  let l:raw_line = getline('.')
  let l:charcount = strlen(substitute(l:raw_line, '\s\+', '', 'g')) " без пробелов
  return printf('%3d%% | %d/%d | %d', l:line * 100 / l:total, l:line, l:total, l:charcount)
endfunction

let g:airline_section_z = '%{MyCleanAirlineRight()}'

" убрать лишнее
let g:airline_section_y = ''
let g:airline_section_warning = ''
let g:airline_section_error = ''
let g:airline_section_info = ''
let g:airline_section_x = ''
let g:airline_section_y = ''


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
tnoremap <C-BS> <C-\><C-n>:tabnext<CR>
nnoremap <C-BS> :tabnext<CR>
inoremap <C-BS> <Esc>:tabnext<CR>
vnoremap <C-BS> <Esc>:tabnext<CR>

" --- Ctrl+Shift+Tab: переход в предыдущий таб
tnoremap <C-SPACE> <C-\><C-n>:tabprevious<CR>
nnoremap <C-SPACE> :tabprevious<CR>
inoremap <C-SPACE> <Esc>:tabprevious<CR>
vnoremap <C-SPACE> <Esc>:tabprevious<CR>


" --- Терминал: выход по <Esc> ---
tnoremap <Esc> <C-\><C-n>

" Показывать airline даже в терминале
let g:airline#extensions#term#enabled = 1

" пока не знаю, но надо
set laststatus=3

" отключает авто коментарии для новых строк после коментаря 
autocmd FileType * setlocal formatoptions-=cro

" Вставка: отключить относительную нумерацию
autocmd InsertEnter * set norelativenumber

" Выход из вставки: снова включить относительную
autocmd InsertLeave * set relativenumber


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
set shell=zsh
set shellcmdflag=-i
set shellquote=
set shellxquote=
set termguicolors


" --- Управление --- "
let mapleader = "\\"

" вернутся на стартовое окно по \d
nnoremap <Leader>d :Dashboard<CR>

" открыть терминал \t
nnoremap <Leader>t :lua OpenTerminalTab()<CR>

" новый таб на \s
"nnoremap <Leader>s :lua require('telescope.builtin').find_files()<CR>
nnoremap <Leader>s :lua OpenSearchTab()<CR>

" \q: закрыть текущий таб
nnoremap <Leader>q :tabclose<CR>

" Ctrl+Tab: переходит в следующий таб из любого режима (в том числе терминала)
tnoremap <A-BS> <C-\><C-n>:tabnext<CR>
nnoremap <A-BS> :tabnext<CR>
inoremap <A-BS> <Esc>:tabnext<CR>
vnoremap <A-BS> <Esc>:tabnext<CR>

tnoremap <C-BS> <C-\><C-n>:tabnext<CR>
nnoremap <C-BS> :tabnext<CR>
inoremap <C-BS> <Esc>:tabnext<CR>
vnoremap <C-BS> <Esc>:tabnext<CR>

" Ctrl+Shift+Tab: переход в предыдущий таб
tnoremap <C-SPACE> <C-\><C-n>:tabprevious<CR>
nnoremap <C-SPACE> :tabprevious<CR>
inoremap <C-SPACE> <Esc>:tabprevious<CR>
vnoremap <C-SPACE> <Esc>:tabprevious<CR>

" Комментировать выделенное по нажатию /
xnoremap / :Commentary<CR>

" Сдвигать выделенное влево/вправо с помощью Tab и Shift+Tab
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv


xnoremap <leader>r :<C-u>call ReplaceSelectedText()<CR>

" Терминал: выход по <Esc>
tnoremap <Esc> <C-\><C-n>





" --- Плагины ---
call plug#begin('~/.vim/plugged')
Plug 'mattn/emmet-vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvimdev/dashboard-nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'windwp/nvim-autopairs'
Plug 'tpope/vim-commentary'
" цветовые схемы
Plug 'srcery-colors/srcery-vim'
Plug 'lunarvim/horizon.nvim'
Plug 'arzg/vim-colors-xcode'
Plug 'joshdick/onedark.vim'
Plug 'bcicen/vim-vice'

call plug#end()



" --- Цветовая схема ---
colorscheme srcery
" colorscheme horizon
" colorscheme xcodedark
" colorscheme onedark
"colorscheme vice

" " Сделать подсветку Visual менее яркой
" highlight Visual ctermbg=8 guibg=#3e4451





function! ReplaceSelectedText()
  " Восстанавливаем визуальное выделение и сохраняем в регистр s
  normal! gv"sy

  " Получаем текст из регистра
  let l:old = getreg("s")

  " Если ничего не выделено — выводим ошибку
  if empty(l:old)
    echoerr "Ошибка: ничего не выделено"
    return
  endif

  " Запрос на замену
  let l:new = input('Заменить на: ')

  " Экранируем спецсимволы
  let l:old_escaped = escape(l:old, '/\.*$^~[]')

  " Выполняем замену по всему буферу
  execute '%s/' . l:old_escaped . '/' . l:new . '/g'
endfunction

" --- airline ---
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#fnamemod = ':t'

" настройка табов
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#tab_nr_type = 0

let g:airline#extensions#tabline#formatter = 'custom'

" Автообновление Airline Tabline после закрытия таба
autocmd TabClosed * if exists('*AirlineRefresh') | call AirlineRefresh() | endif
autocmd TabEnter * if exists('*AirlineRefresh') | call AirlineRefresh() | endif


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


" --- Открывать сначала терминал в директории файла (если файл есть) ---
autocmd VimEnter * call SetupTabs()

" ——— Функция логирования ———
function! Log(msg)
  let l:logfile = expand('~/nvim_startup.log')
  call writefile([strftime("%Y-%m-%d %H:%M:%S") . ' ' . a:msg], l:logfile, 'a')
endfunction


" --- Автоматически открывать терминал + файл при запуске nvim ---

function! SetupTabs()
  if exists('g:term_tabnr') | return | endif
  tabnew | term
  let g:term_tabnr = tabpagenr()
endfunction

function! SetupTermDir()
  execute g:term_tabnr . 'tabnext'
  if exists('b:terminal_job_id')
    call chansend(b:terminal_job_id, "cd " . fnameescape(g:start_dir) . "\n")
  endif
  tabnext
endfunction

" Когда файл открыт вручную — тоже отправим cd в терминал
function! SwitchTermDirOnFileOpen()
  if &buftype != '' | return | endif
  if !exists('g:term_tabnr') | return | endif

  let l:dir = expand('%:p:h')
  let g:start_dir = l:dir

  " Переключаемся на терминальный таб
  execute g:term_tabnr . 'tabnext'

  " Отправляем команду cd в терминал
  if exists('b:terminal_job_id')
    call chansend(b:terminal_job_id, "cd " . fnameescape(l:dir) . "\n")
  endif

  " Возвращаемся назад
  tabnext
endfunction

function! ConditionalStartupTabs()
  if argc() == 0
    " никаких табов — пусть dashboard покажется сам
    return
  endif

  " иначе — запущен с файлом, делаем всё как ты хочешь
  call SetupTabs()
endfunction


autocmd VimEnter * if argc() != 0 | call SetupTabs() | endif


" Триггеры
autocmd VimEnter * call ConditionalStartupTabs()
autocmd BufReadPost * call SwitchTermDirOnFileOpen()


let g:term_tabnr = tabpagenr()



tnoremap <Esc> <C-\><C-n>

" --- Создание директории ---
autocmd BufWritePre * silent! call mkdir(expand('%:p:h'), 'p')


" --- Убиваем все окна по :q или :wq ---
command! Q tabdo q! | redraw!
command! WQ wall | tabdo q! | redraw!

cnoreabbrev q Q
cnoreabbrev wq WQ


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

" автосохранение 
set updatetime=300
autocmd InsertLeave,TextChanged,TextChangedI * silent! wall


" стартовое окно
lua << EOF
require("dashboard").setup({
  theme = "hyper",
  config = {
    header = {
"----------------------------------",
"                 ／＞'''フ        ",
"                 |  _　_|         ",
"              ／` ミ＿xノ         ",
"             /　　     |          ",
"            /　 ヽ　　 ﾉ          ",
"            │　　|　|　|          ",
"       ／￣|　　 |　|　|          ",
"       (￣ヽ＿___ヽ_)__)          ",
"       ＼二)ℒ𝓸𝓿𝒆 𝔂𝓸𝓾              ",
"----------------------------------",
    },
    shortcut = {
      {
        desc = " Files",
        group = "Label",
        action = "Telescope find_files",
        key = "f",
      },
      {
        desc = " Recents",
        group = "Label",
        action = "Telescope oldfiles",
        key = "r",
      },
      {
        desc = " Config",
        group = "Label",
        action = "edit ~/.config/nvim/init.vim",
        key = "c",
      },
    },
    footer = { "" },
  },
})
EOF

" отображать только редактируемые файлы
lua << EOF
require('telescope').setup({
  defaults = {
    find_command = {
      "fd",
      "--type", "f",
      "--hidden",
      "--exclude", ".git",
      "--exclude", "node_modules",
      "--exclude", "venv",
      "--exclude", "build",
      "--exclude", "*.o",
      "--exclude", "*.so",
      "--exclude", "*.exe",
      "--exclude", "*.dll",
      "--exclude", "*.bin",
      "--exclude", "*.class",
      "--exclude", "*.pyc",
      "--exclude", "*.jpg",
      "--exclude", "*.jpeg",
      "--exclude", "*.png",
      "--exclude", "*.gif",
      "--exclude", "*.ttf",
      "--exclude", "*.woff",
      "--exclude", "*.zip",
      "--exclude", "*.tar",
      "--exclude", "*.pdf",
      "--exclude", "*.mp3",
      "--exclude", "*.mp4",
      "--exclude", "*.avi",
      "--exclude", "*.ico",
    }
  }
})
EOF

" ---- авто скобки ----
lua << EOF
require("nvim-autopairs").setup {}
EOF


function! SwitchTermToFileDir()
  let l:dir = expand('%:p:h')
  if &buftype == 'terminal' && exists('b:terminal_job_id')
    execute 'lcd' fnameescape(l:dir)
    call chansend(b:terminal_job_id, "cd " . l:dir . "\n")
  endif
endfunction


" При открытии любого файла запускаем функцию
autocmd BufReadPost * call SwitchTermToFileDir()

" настройка coc "
inoremap <silent><expr> <CR> pumvisible()
  \ ? coc#_select_confirm()
  \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" new таб
lua << EOF
function OpenSearchTab()
  local api = vim.api

  -- Убедимся, что терминал создан
  if vim.g.term_tabnr == nil then
    vim.cmd("tabnew | term")
    vim.g.term_tabnr = api.nvim_get_current_tabpage()
  end

  -- Создаём таб перед терминалом
  local term_tab = vim.g.term_tabnr
  vim.cmd((term_tab) .. "tabnew")

  -- Запускаем Telescope
  require('telescope.builtin').find_files()
end
EOF


lua << EOF
function OpenTerminalTab()
  local dir = vim.fn.expand('%:p:h')
  vim.cmd("tablast | tabnew | term")
  vim.g.term_tabnr = vim.api.nvim_get_current_tabpage()
  if vim.b.terminal_job_id then
    vim.fn.chansend(vim.b.terminal_job_id, "cd " .. dir .. "\n")
  end
end
EOF


lua << EOF
function OpenSearchTab()
  local api = vim.api
  local tab_count = api.nvim_list_tabpages()

  -- Если терм вкладка не валидна, пересоздаем
  if vim.g.term_tabnr == nil or vim.g.term_tabnr > #tab_count then
    vim.cmd("tabnew | term")
    vim.g.term_tabnr = api.nvim_get_current_tabpage()
  end

  -- Создаем таб перед терминалом
  local term_tab = vim.g.term_tabnr
  api.nvim_set_current_tabpage(term_tab)
  vim.cmd("tabnew")

  -- Запускаем Telescope
  require('telescope.builtin').find_files()
end
EOF

let mapleader = " "
let g:bigfile_size = 1024 * 1024 * 1.5 " 1.5MB

" Compatibility & Encoding
set encoding=UTF-8 " Set file encoding to UTF-8
set nocompatible " Enable modern Vim features

" Clipboard Settings
" set clipboard=unnamed " Use system clipboard for copy-paste

" Search & Navigation
set hlsearch " Highlight search results
set ignorecase " Case-insensitive search
set incsearch " Show search matches while typing
set smartcase " Case-sensitive if uppercase letters are used

" User Interface & Display
set number " Show line numbers
set relativenumber " Show relative line numbers
set scrolloff=4 " Keep 4 lines visible above/below cursor
set sidescrolloff=8 " Keep 8 columns visible when scrolling horizontally
set conceallevel=0 " Show all concealed text
set laststatus=2 " Always show status line (for lightline)
set showtabline=2 " Show tab bar when multiple tabs exist
set noshowmode " Hide mode indicator (for lightline)
set fillchars=eob:\ " No tidle '~' in eob
set shortmess=AcqFI " Reduce message clutter

" Cursor & Mouse Behavior
set mouse=a " Enable mouse support
set nocursorcolumn " Disable highlighting of the cursor column
set nocursorline " Disable highlighting of the cursor line
set whichwrap+=<,>,[,],h,l " Allow wrapping with arrow keys

" File Handling & Backup
set nobackup " Disable backup files
set noswapfile " Disable swap files
set nowb " Disable write backup
set undofile

" Regular Expressions & Search Engine
set regexpengine=0 " Automatically choose the best regex engine

" Clipboard & File Completion
set wildignorecase " Case-insensitive command/file completion

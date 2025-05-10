" Cursor stuff
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:Cursor/lCursor,sm:block

" No delay on esc?
set ttimeout
set ttimeoutlen=1
set ttyfast

" Color & Visual Enhancements
set termguicolors " Enable true color support (for Catppuccin theme)

set expandtab " Use space instead tab
set shiftwidth=2
set tabstop=2


syntax on

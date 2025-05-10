" Set to auto read when a file is changed from the outside
set autoread
au FocusGained,BufEnter * silent! checktime

autocmd VimEnter * silent !echo -ne "\e[2 q"

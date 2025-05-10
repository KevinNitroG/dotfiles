" Return to last edit position when opening files (You want this!)
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Set tab 4 for those fts
autocmd FileType c,cpp,cs,py set tabstop=4 shiftwidth=4 expandtab

" q to close those fts
autocmd FileType Avante,dbout,git,fugitiveblame,help setlocal nobuflisted | nnoremap <buffer> q :close<CR>

" Create dir when save
autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")

" DetectBigfile
autocmd BufReadPre * call BigFile()


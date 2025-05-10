let NERDTreeDirArrowExpandable = ''
let NERDTreeDirArrowCollapsible = ''
let NERDTreeMinimalUI=1
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1


nnoremap <leader>e :NERDTreeToggle<CR>

" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif

" Relative line number
autocmd FileType nerdtree setlocal relativenumber

inoremap jk <Esc>

" Save
nnoremap <C-s> :w<CR>
inoremap <C-s> <cmd>w<CR>

" Yank to Last
nnoremap Y y$

" Set No Highlight
nnoremap <Esc> :noh<return>

" Yank All
nnoremap <leader>y :%y+<return>

" Toggle Wrap
nnoremap <leader>ow :set wrap!<CR>

" Close current window
nnoremap <leader>w :close<CR>
nnoremap sq :close<CR>

" Better Down
" nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')

" Better Up
" nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')

" Go to upper window
nnoremap <C-j> <C-w>j
vnoremap <C-j> <C-w>j

" Go to lower window
nnoremap <C-k> <C-w>k
vnoremap <C-k> <C-w>k

" Go to left window
nnoremap <C-h> <C-w>h
vnoremap <C-h> <C-w>h

" Go to right window
nnoremap <C-l> <C-w>l
vnoremap <C-l> <C-w>l

" Move the line up
nnoremap <A-j> :m .+1<CR>==

" Move the line down
nnoremap <A-k> :m .-2<CR>==

" Move selected lines up (Visual Mode)
vnoremap <A-j> :m '>+1<CR>gv=gv

" Move selected lines down (Visual Mode)
vnoremap <A-k> :m '<-2<CR>gv=gv

" Indent backward (Visual Mode)
vnoremap < <gv

" Indent forward (Visual Mode)
vnoremap > >gv

" Better Paste (Visual Mode)
vnoremap p "_dP

" Sort (Visual Mode)
vnoremap <leader>us :sort<CR>gv<ESC>

" Sort Unique (Visual Mode)
vnoremap <leader>uu :sort u<CR>gv<ESC>

" Navigate buffer
nnoremap H :bprevious<CR>
nnoremap L :bnext<CR>

" Close buffer
" nnoremap <leader>c :Bclose<cr>
nnoremap <leader>C :bufdo bdelete<cr>

" Resize window
nnoremap <C-right> :vertical resize +2<CR>
nnoremap <C-left> :vertical resize -2<CR>
nnoremap <C-up> :resize +2<CR>
nnoremap <C-down> :resize -2<CR>

" Navigate tab
nnoremap <Left> :tabprevious<CR>
nnoremap <Right> :tabnext<CR>
nnoremap <Up> :tabnew<CR>
nnoremap <Down> :tabclose<CR>

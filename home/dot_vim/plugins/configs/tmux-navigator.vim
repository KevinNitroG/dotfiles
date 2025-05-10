" TODO: Check if tmux running or not too
if has('win32')
  let g:tmux_navigator_no_mappings = 1

  nnoremap <silent> <C-h> :<C-U>TmuxNavigateLeft<cr>
  nnoremap <silent> <C-j> :<C-U>TmuxNavigateDown<cr>
  nnoremap <silent> <C-k> :<C-U>TmuxNavigateUp<cr>
  nnoremap <silent> <C-l> :<C-U>TmuxNavigateRight<cr>
  nnoremap <silent> <C-\> :<C-U>TmuxNavigatePrevious<cr>
else
  nnoremap <silent> <C-h> <C-w>h
  nnoremap <silent> <C-j> <C-w>j
  nnoremap <silent> <C-k> <C-w>k
  nnoremap <silent> <C-l> <C-w>l
endif

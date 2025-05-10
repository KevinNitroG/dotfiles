function! BigFile()
  let l:path = expand('<afile>:p')
  if getfsize(l:path) > g:bigfile_size
    setlocal syntax=
    setlocal nospell
    setlocal smoothie_enabled=0
  endif
endfunction

" From amix/vimrc
" Don't close window, when deleting a buffer
" command! Bclose call <SID>BufcloseCloseIt()
" function! <SID>BufcloseCloseIt()
"     let l:currentBufNum = bufnr("%")
"     let l:alternateBufNum = bufnr("#")
"
"     if buflisted(l:alternateBufNum)
"         buffer #
"     else
"         bnext
"     endif
"
"     if bufnr("%") == l:currentBufNum
"         new
"     endif
"
"     if buflisted(l:currentBufNum)
"         execute("bdelete! ".l:currentBufNum)
"     endif
" endfunction

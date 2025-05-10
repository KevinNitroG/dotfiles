nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
set timeoutlen=500

let g:which_key_map = {}
let g:which_key_map['f'] = { 'name': 'Find' }
let g:which_key_map['o'] = { 'name': 'Options' }
let g:which_key_map['p'] = { 'name': 'Plugins' }

call which_key#register('<Space>', "g:which_key_map")

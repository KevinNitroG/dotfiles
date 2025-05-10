" autocmd VimEnter * PlugInstall --sync | source $MYVIMRC

call plug#begin()

" Plug 'alker0/chezmoi.vim'
" Plug 'sheerun/vim-polyglot'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
if has('win32')
  Plug 'christoomey/vim-tmux-navigator'
endif
Plug 'LunarWatcher/auto-pairs'
Plug 'andymass/vim-matchup'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vim-which-key'
Plug 'machakann/vim-highlightedyank'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'mg979/vim-visual-multi', { 'branch': 'master' }
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'psliwka/vim-smoothie'
Plug 'qpkorr/vim-bufkill'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tribela/vim-transparent'
Plug 'wellle/targets.vim'
Plug 'zivyangll/git-blame.vim'

if filereadable(expand("$HOME") . "/.wakatime.cfg")
  Plug 'wakatime/vim-wakatime'
endif

call plug#end()

if !empty($CATPPUCCIN_FLAVOR)
  let catppuccin_flavor = $CATPPUCCIN_FLAVOR
else
  let catppuccin_flavor = 'mocha'
endif

let colorscheme = 'catppuccin-' . catppuccin_flavor

execute 'colorscheme ' . colorscheme

let g:lightline = {'colorscheme': 'catppuccin'}

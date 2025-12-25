if !exists('g:enable_background') || g:enable_background == 0
  hi Normal guibg=NONE ctermbg=NONE
  hi NonText guibg=NONE
  hi SpecialKey guibg=NONE
  hi LineNr guibg=NONE
  hi StatusLine guibg=NONE
  hi Folded guibg=NONE
  hi EndOfBuffer guibg=NONE
  hi NormalNC guibg=NONE
  hi SignColumn guibg=NONE
  hi NormalFloat guibg=NONE
  hi FloatBorder guibg=NONE
  hi CursorLine guibg=NONE
endif
hi CursorLine gui=underline guibg=NONE

" plugin
" quick scope
highlight QuickScopePrimary gui=bold
highlight QuickScopeSecondary gui=bold


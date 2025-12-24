if g:disable_auto_theme_change == 0
  let time = str2nr(strftime('%H'))

  if 5 >= time || time >= 18
    set background=dark
    colorscheme everforest
  else
    set background=light
    colorscheme catppuccin_latte
  endif
else
  set background=dark
  colorscheme everforest
endif

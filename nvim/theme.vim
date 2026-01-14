if exists('g:disable_auto_theme_change') && g:disable_auto_theme_change == 1
  set background=dark
  colorscheme everforest
else
  let time = str2nr(strftime('%H'))

  if 5 >= time || time >= 18
    set background=dark
    colorscheme everforest
  else
    set background=light
    colorscheme catppuccin_latte
  endif
endif

if exists('g:disable_auto_theme_change') && g:disable_auto_theme_change == 1
  set background=dark
  colorscheme catppuccin_frappe
else
    set background=dark
    colorscheme catppuccin_frappe
endif

command! HighlightDark :set background=dark | colorscheme catppuccin-frappe
command! HighlightLight :set background=light | colorscheme everforest

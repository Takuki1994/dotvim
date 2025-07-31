if system('powershell.exe Get-ItemProperty
      \ -Path \"HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize\"
      \ -Name AppsUseLightTheme
      \ | rg AppsUse | perl -lane "{print $F[2]}"') == 0
  set background=dark
  let g:everforest_background = 'soft'
  colorscheme everforest
  " airline
  let g:airline_theme = 'everforest'
else
  set background=light
  let g:everforest_background = 'hard'
  colorscheme everforest
  " airline
  let g:airline_theme = 'everforest'
endif

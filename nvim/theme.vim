let path = expand(g:nvim_home . '/.dark_mode')
let time = str2nr(strftime('%y%m%d%H%M'))
      \- str2nr(strftime('%y%m%d%H%M', getftime(path)))

if time >= g:background_check_time
  let dark_mode = system('powershell.exe Get-ItemProperty
        \ -Path \"HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize\"
        \ -Name AppsUseLightTheme
        \ | rg AppsUse | perl -lane "{print $F[2]}"') == 0
  execute 'redir! > ' . path
    silent! echon 'let g:dark_mode=' . dark_mode
  redir END
  echo 'update .dark_mode'
endif

source `=g:nvim_home . '/.dark_mode'`

if g:dark_mode
  set background=dark
else
  set background=light
endif
colorscheme everforest

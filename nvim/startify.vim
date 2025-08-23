lua << EOF
  local alpha = require("alpha")
  local dashboard = require("alpha.themes.dashboard")
  local logo_key_list = {
    'neovim',
    'bluearchive',
    'zenless'
  }
  math.randomseed(os.time())
  local logo_key = logo_key_list[math.random(#logo_key_list)]
  if logo_key == 'bluearchive' then
    dashboard.section.header.val = {
      "                    Independent Federal Investigation Club",
      " ▄▄▄▄           ▄▄▄         ▄    ▄          ▄▄          ▄             ▄▄▄▄▄▄",
      "█▀   ▀        ▄▀   ▀        █    █          ██          █             █     ",
      "▀█▄▄▄         █             █▄▄▄▄█         █  █         █             █▄▄▄▄▄",
      "    ▀█        █             █    █         █▄▄█         █             █     ",
      "▀▄▄▄█▀   █     ▀▄▄▄▀   █    █    █   █    █    █   █    █▄▄▄▄▄   █    █▄▄▄▄▄",
   }
    dashboard.section.header.opts = {
      hl = "Blue",
      position = "center"
    }
    dashboard.section.footer.val = {
      '私が先生のお仕事を手伝います！'
    }
    dashboard.section.footer.opts = {
      hl = "Blue",
      position = "center"
    }
  elseif logo_key == 'zenless' then
    dashboard.section.header.val = {
      ' ▄▄    ▄▄            ▄▄▄▄▄               ▄▄▄▄▄    ',
      ' ██    ██            ██▀▀▀██             ██▀▀▀██  ',
      ' ██    ██            ██    ██            ██    ██ ',
      ' ████████            ██    ██            ██    ██ ',
      ' ██    ██            ██    ██            ██    ██ ',
      ' ██    ██     ██     ██▄▄▄██      ██     ██▄▄▄██  ',
      ' ▀▀    ▀▀     ▀▀     ▀▀▀▀▀        ▀▀     ▀▀▀▀▀    ',
   }
    dashboard.section.header.opts = {
      hl = "Fg",
      position = "center"
    }
    dashboard.section.footer.val = {
      'マスター、あなたの忠実な僕Fairyは準備万端です'
    }
    dashboard.section.footer.opts = {
      hl = "Fg",
      position = "center"
    }
  else
    local logo = require("ascii").art.text.neovim.sharp
    dashboard.section.header.val = logo
  end
  dashboard.section.buttons.val = {
    dashboard.button( "e", "  > New file" , ":ene <BAR> startinsert <CR>"),
    dashboard.button( "s", "  > Search fzf", "<Cmd>Files<CR>"),
    dashboard.button( "q", "󰅚  > Quit", "<Cmd>qa<CR>"),
  }
EOF

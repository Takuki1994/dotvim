lua << EOF
  local alpha = require("alpha")
  local dashboard = require("alpha.themes.dashboard")

  -- cmdでnvim起動時のプロセスリストを取得して特定のプロセスが存在するか確認する関数
  local result = vim.fn.system("tasklist")
  local function is_process_running(process_name)
    for line in result:gmatch("[^\r\n]+") do
      if line:find(process_name) then
        return true
      end
    end
    return false
  end
  if is_process_running("BlueArchive.exe") then
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
      'スーパーアロナちゃんにおまかせください！'
    }
    dashboard.section.footer.opts = {
      hl = "Blue",
      position = "center"
    }
  elseif is_process_running("ZenlessZoneZero.exe") then
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
      'マスター、あなたの忠実なAI、Fairyにお任せください'
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
    dashboard.button( "f", "  > Search file", "<Cmd>Files<CR>"),
    dashboard.button( "r", "  > Move repositories directory",
              "<Cmd>call fzf#run({'source': 'ghq list -p', 'sink': 'cd', 'window': {'width': 0.9, 'height': 0.6}})<CR>"),
    dashboard.button( "m", "  > Create scratch",
              "<Cmd>:ene|:setl bt=nofile bh=hide noswapfile|:file memo<CR>"),
    dashboard.button( "g", "󰊠  > Start GhostText", "<Cmd>GhostStart<CR>"),
    dashboard.button( "q", "󰅚  > Quit", "<Cmd>qa<CR>"),
  }
  dashboard.config.layout = {
    { type = "group", opts = {
        position = "v_center"
      },
      val = {
        dashboard.section.header,
        {type = "padding", val = 5},
        dashboard.section.buttons,
        {type = "padding", val = 3},
        dashboard.section.footer,
      },
    },
  }
EOF

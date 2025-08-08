" plugin install
packadd vim-jetpack
call jetpack#begin()
Jetpack 'tani/vim-jetpack', {'opt': 1} "bootstrap
Jetpack 'unblevable/quick-scope'
Jetpack 'machakann/vim-sandwich'
Jetpack 'easymotion/vim-easymotion'

if !exists('g:vscode')
  Jetpack 'dinhhuy258/git.nvim'
  Jetpack 'lewis6991/gitsigns.nvim'
  Jetpack 'https://github.com/lukas-reineke/indent-blankline.nvim'
  Jetpack 'neoclide/coc.nvim', { 'branch': 'release' }
  Jetpack 'vim-airline/vim-airline'
  Jetpack 'vim-airline/vim-airline-themes'
  Jetpack 'mfussenegger/nvim-dap'
  Jetpack 'mfussenegger/nvim-dap-python'
  Jetpack 'sainnhe/everforest'
  Jetpack 'ryanoasis/vim-devicons'
  Jetpack 'MeanderingProgrammer/render-markdown.nvim'
  Jetpack 'gosukiwi/vim-smartpairs'
  Jetpack 'dominikduda/vim_current_word'
  Jetpack 'nvim-treesitter/nvim-treesitter'
  Jetpack 'nvim-tree/nvim-web-devicons'
  Jetpack 'nvim-treesitter/nvim-treesitter-context'
  Jetpack 'Shougo/ddc.vim'
  Jetpack 'Shougo/ddc-ui-native'
  Jetpack 'junegunn/fzf'
  Jetpack 'junegunn/fzf.vim'
  Jetpack 'norcalli/nvim-colorizer.lua'
endif
Jetpack 'vim-denops/denops.vim'
Jetpack 'lambdalisue/vim-gin'
Jetpack 'bullets-vim/bullets.vim'
Jetpack 'vim-jp/vimdoc-ja'
Jetpack 'vim-skk/skkeleton'
Jetpack 'yasunori0418/statusline_skk.vim'

call jetpack#end()

for name in jetpack#names()
  if !jetpack#tap(name)
    call jetpack#sync()
    break
  endif
endfor

" helpを日本語化
set helplang=ja,en

" airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline_section_a = g:airline#section#create([
      \'mode',
      \'crypt',
      \'paste',
      \'spell',
      \'iminsert',
      \'executable',
      \'%{statusline_skk#mode()}'])
let g:airline_section_x = g:airline#section#create([
      \'filetype',
      \'  %{strftime("%T")}'
      \])

" ddc.vim
function DdcSettings() abort
  call ddc#custom#patch_global('ui', 'native')
  call ddc#custom#patch_global('sources', ['skkeleton'])
  call ddc#custom#patch_global('sourceOptions', {
  \ 'skkeleton': {
  \   'mark': 'skkeleton',
  \   'matchers': [],
  \   'sorters': [],
  \   'converters': [],
  \   'isVolatile': v:true,
  \   'minAutoCompleteLength': 1,
  \  },
  \ })
  call ddc#enable()
endfunction

function! EnableDdc() abort
  let b:coc_suggest_disable = v:true
  call DdcSettings()
endfunction
function! DisableDdc() abort
  let b:coc_suggest_disable = v:false
  call ddc#custom#patch_global('sourceOptions', {})
endfunction

" skkeleton
call skkeleton#initialize()
imap <C-j> <Plug>(skkeleton-toggle)
cmap <C-j> <Plug>(skkeleton-toggle)
function! s:skkeleton_init() abort
   call skkeleton#config({
     \ 'eggLikeNewline': v:true,
     \ 'globalDictionaries': ['~\.config\skk\SKK-JISYO.L']
     \ })
   call skkeleton#register_kanatable('rom', {
     \ "z\<Space>": ["\u3000", ''],
     \ })
endfunction
augroup skkeleton-initialize-pre
  autocmd!
  autocmd User skkeleton-initialize-pre call s:skkeleton_init()
augroup END
call skkeleton#config({
  \ 'eggLikeNewline': v:true,
  \ 'globalDictionaries': ['~\.config\skk\SKK-JISYO.L']
  \ })
augroup skkeleton-coc
  autocmd!
  autocmd User skkeleton-enable-pre call EnableDdc()
  autocmd User skkeleton-disable-pre call DisableDdc()
augroup END

" statusline_skk
call statusline_skk#option('display', {
  \ 'hiragana': '   あぁ',
  \ 'katakana': '   アァ',
  \ 'hankaku-katakana': '   ｱｧ',
  \ 'zenkaku-alphabet': '   Ａａ',
  \ 'alphabet': '   Aa',
  \ })
let g:lightline_skk_announce = v:true

" DAP
if !exists('g:vscode')
lua << EOF
  require('dap-python').setup('uv')
  require('dap-python').test_runner = 'pytest'
  vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
  vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
  vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
  vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
  vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
  vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
  vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
  vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
  vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
  vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
    require('dap.ui.widgets').hover()
  end)
  vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
    require('dap.ui.widgets').preview()
  end)
  vim.keymap.set('n', '<Leader>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.frames)
  end)
  vim.keymap.set('n', '<Leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
  end)
  require("dap").adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
  }
  local dap = require("dap")
  dap.configurations.c = {
    {
      name = "Launch",
      type = "gdb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = "${workspaceFolder}",
      stopAtBeginningOfMainSubprogram = false,
    },
    {
      name = "Select and attach to process",
      type = "gdb",
      request = "attach",
      program = function()
         return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      pid = function()
         local name = vim.fn.input('Executable name (filter): ')
         return require("dap.utils").pick_process({ filter = name })
      end,
      cwd = '${workspaceFolder}'
    },
    {
      name = 'Attach to gdbserver :1234',
      type = 'gdb',
      request = 'attach',
      target = 'localhost:1234',
      program = function()
         return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}'
    },
  }
EOF
endif

" zenhan
" IME off
if executable('zenhan')
  augroup zenhan
    autocmd!
    autocmd ModeChanged *:n call system('zenhan 0')
    autocmd CmdlineLeave * :call system('zenhan 0')
  augroup END
endif

if exists('g:vscode')
  "  quick-scope
  highlight QuickScopePrimary
        \ guifg='#91d350' gui=underline ctermfg=155 cterm=underline
  highlight QuickScopeSecondary
        \ guifg='#51dada' gui=underline ctermfg=81 cterm=underline
  "  vim-sandwich
  highlight OperatorSandwichBuns
        \ guifg='#aa91a0' gui=underline ctermfg=172 cterm=underline
  highlight OperatorSandwichChange
        \ guifg='#edc41f' gui=underline ctermfg='yellow' cterm=underline
  highlight OperatorSandwichAdd
        \ guibg='#b1fa87' gui=none ctermbg='green' cterm=none
  highlight OperatorSandwichDelete
        \ guibg='#cf5963' gui=none ctermbg='red' cterm=none
else
  " color scheme settings
  " Vim
  source `=g:nvim_home . '/theme.vim'`
  source `=g:nvim_home . '/highlight.vim'`
endif

" lua plugin settings

if !exists('g:vscode')
  " Git
  lua require'git'.setup()
lua << EOF
  require'gitsigns'.setup {
    signcolumn = true,
    numhl = true,
  }
EOF
  " coc.nvim
  nmap <silent> <leader><leader>df <Plug>(coc-definition)
  nmap <silent> <leader><leader>rf <Plug>(coc-references)
  inoremap <silent><expr> <TAB>
    \ coc#pum#visible() ? coc#pum#next(1) :
    \ CheckBackspace() ? "\<Tab>" :
    \ coc#refresh()
  inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
  " Make <CR> to accept selected completion item or notify coc.nvim to format
  " <C-g>u breaks current undo, please make your own choice
  inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() :
    \ "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

  function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction
  " Use <c-space> to trigger completion
  if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
  else
    inoremap <silent><expr> <c-@> coc#refresh()
  endif

endif  " !exists('g:vscode')


set cole=2
lua << EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  }
}
require'treesitter-context'.setup {
  enable = true,
  multiline_threshold = 1,
  trim_scope = 'inner',
  separator = '-',
  mode = 'topline'
}
require('render-markdown').setup({
    heading = {
        width = 'block',
        left_pad = 0,
        right_pad = 4,
        icons = {'# ',},
        sign = false,
    },
})
EOF

" Gin.vim
nmap <silent> <leader><leader>gp <Cmd>tabe%\|:GinPatch ++no-head<CR>
nmap <silent> <leader><leader>gP <Cmd>tabe%\|:GinPatch ++no-worktree<CR>

" colorier.nvim
lua require'colorizer'.setup()

" easymotion
nmap <silent> <leader><leader>f <Plug>(easymotion-fl)
nmap <silent> <leader><leader>F <Plug>(easymotion-Fl)
nmap <silent> <leader><leader>t <Plug>(easymotion-tl)
nmap <silent> <leader><leader>T <Plug>(easymotion-Tl)
let g:EasyMotion_use_migemo = 1

" plugin install
packadd vim-jetpack
call jetpack#begin()
Jetpack 'tani/vim-jetpack', {'opt': 1} "bootstrap
Jetpack 'unblevable/quick-scope'
Jetpack 'machakann/vim-sandwich'
Jetpack 'easymotion/vim-easymotion'
Jetpack 'dinhhuy258/git.nvim'
Jetpack 'lewis6991/gitsigns.nvim'
Jetpack 'https://github.com/lukas-reineke/indent-blankline.nvim'
Jetpack 'sainnhe/everforest'
Jetpack 'gosukiwi/vim-smartpairs'
Jetpack 'dominikduda/vim_current_word'
Jetpack 'junegunn/fzf'
Jetpack 'junegunn/fzf.vim'
Jetpack 'norcalli/nvim-colorizer.lua'
Jetpack 'goolord/alpha-nvim'
Jetpack 'MaximilianLloyd/ascii.nvim'
Jetpack 'bullets-vim/bullets.vim'
Jetpack 'vim-jp/vimdoc-ja'
" Node.js依存
Jetpack 'nvim-treesitter/nvim-treesitter'
Jetpack 'nvim-treesitter/nvim-treesitter-context'
" deno依存
Jetpack 'vim-denops/denops.vim'
Jetpack 'vim-skk/skkeleton'
Jetpack 'lambdalisue/vim-gin'
Jetpack 'Shougo/ddc.vim'
Jetpack 'Shougo/ddc-ui-native'

call jetpack#end()

for name in jetpack#names()
  if !jetpack#tap(name)
    call jetpack#sync()
    break
  endif
endfor

" helpを日本語化
set helplang=ja,en

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
  call ddc#custom#patch_buffer('specialBufferCompletion', v:true)
  call ddc#enable()
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
call DdcSettings()

" zenhan
" IME off
if executable('zenhan')
  augroup zenhan
    autocmd!
    autocmd ModeChanged *:n call system('zenhan 0')
    autocmd CmdlineLeave * :call system('zenhan 0')
  augroup END
endif

"  quick-scope
let g:qs_second_highlight = 0
" color scheme settings
" Vim
source `=g:nvim_home . '/theme.vim'`
source `=g:nvim_home . '/highlight.vim'`

" lua plugin settings
" Git
lua require'git'.setup()
lua << EOF
  require'gitsigns'.setup {
    signcolumn = true,
    numhl = true,
  }
EOF

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
EOF

" Gin.vim
nnoremap <silent> <leader>gp <Cmd>tabedit%\|:GinPatch ++no-head<CR>
nnoremap <silent> <leader>gP <Cmd>tabedit%\|:GinPatch ++no-worktree<CR>
nnoremap <silent> <leader>gl <Cmd>:GinLog --oneline --graph<CR>
nnoremap <silent> <leader>gL <Cmd>:GinLog --oneline --graph<CR>
nnoremap <silent> <leader>gs <Cmd>tabedit\|:GinStatus<CR>
nnoremap <silent> <leader>gd <Cmd>tabedit\|:GinDiff<CR>
nnoremap <silent> <leader>gA <Cmd>:Gin add -A<CR>
nnoremap <silent> <leader>gc <Cmd>:Gin commit -v<CR>

" colorier.nvim
lua require'colorizer'.setup()

" easymotion
nmap <silent> <leader><leader>f <Plug>(easymotion-fl)
nmap <silent> <leader><leader>F <Plug>(easymotion-Fl)
nmap <silent> <leader><leader>t <Plug>(easymotion-tl)
nmap <silent> <leader><leader>T <Plug>(easymotion-Tl)
let g:EasyMotion_use_migemo = 1

" alpha-nvim
source `=g:nvim_home . '/startify.vim'`
lua require'alpha'.setup(require'alpha.themes.dashboard'.config)
augroup alpha-nvim
  autocmd FileType alpha setlocal scrolloff=0
augroup END

" fzf.vim
nnoremap <silent> <leader>fe :Files<CR>
nnoremap <silent> <leader>fg :GFiles<CR>
nnoremap <silent> <leader>f? :GFiles?<CR>
nnoremap <silent> <leader>fb :Buffers<CR>
nnoremap <silent> <leader>ft :call fzf#run({'sink': 'tabe'})<CR>
nnoremap <silent> <leader>fv :call fzf#run({'sink': 'vs'})<CR>
nnoremap <silent> <leader>fs :call fzf#run({'sink': 'sp'})<CR>
nnoremap <silent> <leader>fr :call fzf#run({'source': 'ghq list -p',
                                           \'sink': 'cd'})<CR>

" statusline
function! GetSkkStatusline() abort
  let skk_mode = skkeleton#mode()
  if skk_mode == 'hira'
    return 'あぁ '
  elseif skk_mode == 'kata'
    return 'アァ '
  elseif skk_mode == 'hankata'
    return 'ｱｧ '
  elseif skk_mode == 'zenkaku'
    return 'Ａａ '
  else
    return ''
  endif
endfunction
set statusline=%{GetSkkStatusline()}%<%f\ %y%h%w%m%r%=\ %-14.(%l,%c%V%)\ %P

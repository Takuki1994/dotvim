set shell=cmd

" let g:nvim_home=<nvimフォルダへのパス>
" let g:disable_auto_theme_change=0 
source ~\.config\nvim\.env

" spell settings
syntax on

" vim settings
let mapleader=","
set clipboard=unnamedplus
set scrolloff=5
set termguicolors
set listchars=eol:↴,tab:>.,trail:⋅
set list
set nowrap
set ignorecase
set smartcase
set makeprg=just
" indent settings
set expandtab
set tabstop=4
set shiftwidth=4
set cursorline
set cursorlineopt=line
set textwidth=0
augroup column_highlight
  autocmd!
  autocmd FileType c,cpp setlocal colorcolumn=79
  autocmd FileType vim setlocal colorcolumn=79
  autocmd FileType python setlocal colorcolumn=79
  autocmd FileType git,gitcommit setlocal colorcolumn=79
  autocmd FileType markdown setlocal colorcolumn=79
augroup END
" nvimだと半角カナの濁点の表示とカーソル移動の扱いが一致せず表示が崩れるので
" 応急処置として半角カナをすべて全角と同じ幅で扱う
augroup hankaku_kana
  autocmd!
  autocmd VimEnter * call setcellwidths([[0xff66,0xff9d,2]])
augroup END
set delcombine
filetype plugin on
filetype indent on
augroup filetype_indent
  autocmd!
  autocmd FileType vim setlocal sw=2 sts=2 ts=2 et
augroup END
augroup todo
  autocmd!
  autocmd BufNewFile,BufRead [tT]odo.txt,[iI]nbox.txt,[dD]one.txt
        \ set syntax=todo
augroup END
" laststatus=3はNeoVim限定の設定
set laststatus=3

" keymap
inoremap <Leader><Leader>date <C-R>=strftime('%Y-%m-%d')<CR>
cnoremap <Leader><Leader>date <C-R>=strftime('%Y-%m-%d')<CR>
inoremap <Leader><Leader>time <C-R>=strftime('%Y-%m-%d_%H-%M')<CR>
cnoremap <Leader><Leader>time <C-R>=strftime('%Y-%m-%d_%H-%M')<CR>
let scratch_cmd = ':setlocal buftype=nofile bufhidden=hide noswapfile|:file '
nnoremap <silent> <expr> <Leader>se ':ene\|' . scratch_cmd
      \. input('scratch name: ') . '<CR>'
nnoremap <silent> <expr> <Leader>st ':tabe\|' . scratch_cmd
      \. input('scratch name: ') . '<CR>'
nnoremap <silent> <expr> <Leader>sv ':vs\|:ene\|' . scratch_cmd
      \. input('scratch name: ') . '<CR>'
nnoremap <silent> <expr> <Leader>ss ':sp\|:ene\|' . scratch_cmd
      \. input('scratch name: ') . '<CR>'
nnoremap <silent> <expr> <Leader>tt ':tabe\|:terminal<CR>file '
      \. input('terminal name: ') . '<CR>'

" plugin
source `=g:nvim_home . '/plugin.vim'`

" grep
set grepprg=rg\ -nHP\ --column\ --crlf\ --path-separator=/
set grepformat=%f:%l:%c:%m

" Typos
command! -nargs=? -complete=file Typos
      \ cexpr system('typos --format brief <args>')
" Ruff
command! -nargs=1 -complete=file Ruff
      \ cexpr system('uv tool run ruff check --output-format concise <args>')
" Ty
command! -nargs=1 -complete=file Ty
      \ cexpr system('uv tool run ty check --output-format concise <args>')
" error[invalid-assignment] main.py:2:5: Object
set errorformat^=%t%.%#\ %f:%l:%c:\ %m
" check trailing whitespace
command! -nargs=1 -complete=file TrailingWhitespace grep "[\ 　\t]+$" <args>
command! -nargs=1 -complete=file Twh TrailingWhitespace <args>
" markdownlint-cli2
command! -nargs=? -complete=file Markdownlint
      \ cexpr system('markdownlint-cli2 <args>')
command! -nargs=? -complete=file Mdl Markdownlint <args>
set errorformat^=%f:%l\ %m
set errorformat^=%f:%l:%c\ %m
" todo.txt
source `=g:nvim_home . '/todo-txt.vim'`

" ディレクトリの自動生成
" 参考：https://vim-jp.org/vim-users-jp/2011/02/20/Hack-202.html
augroup vimrc-auto-mkdir  " {{{
  autocmd!
  autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  function! s:auto_mkdir(dir, force)  " {{{
    if !isdirectory(a:dir) && (a:force ||
    \    input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
      call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
  endfunction  " }}}
augroup END  " }}}

" complete functions
function! CompleteTypos(findstart, base)
    if a:findstart
        " Get cursor word.
        let cur_text = strpart(getline('.'), 0, col('.') - 1)

        return match(cur_text, '\f*$')
    endif

    let words = split(system('set /p x=' . a:base . '|typos - --format brief|perl -pe "s/^.*`.*` should be //;s/[`,]//g"'))
    let list = []
    let cnt = 0
    for word in words
        call add(list, { 'word' : word, 'menu' : 'typos' })
        let cnt += 1
    endfor

    return list
endfunction
set completefunc=CompleteTypos

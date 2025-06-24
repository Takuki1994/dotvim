let $shell="cmd"

" let g:nvim_home=<nvimフォルダへのパス>
source ~\.config\nvim\.env

" spell settings
syntax on

" vim settings
let mapleader="\<Space>"
set clipboard=unnamedplus

set scrolloff=5

if !exists('g:vscode')
  set termguicolors
  set number
  set relativenumber
  set listchars=eol:↴,tab:>.,trail:⋅
  set list
  set nowrap
  " indent settings
  set expandtab
  set tabstop=4
  set shiftwidth=4
  set cursorline
  set cursorlineopt=number
  set textwidth=0
  set colorcolumn=79
  " nvimだと半角カナの濁点の表示とカーソル移動の扱いが一致せず表示が崩れるので
  " 応急処置として半角カナをすべて全角と同じ幅で扱う
  augroup hankaku_kana
    autocmd VimEnter * call setcellwidths([[0xff66,0xff9d,2]])
  augroup END
  set delcombine
  filetype plugin on
  filetype indent on
  augroup filetype_indent
    autocmd FileType vim setlocal sw=2 sts=2 ts=2 et
  augroup END
  augroup todo
    autocmd BufNewFile,BufRead [tT]odo.txt,[iI]nbox.txt,[dD]one.txt set syntax=todo
  augroup END
endif

" plugin
source `=g:nvim_home . '/plugin.vim'`

" grep
set grepprg=rg\ -nHP\ --column\ --crlf\ --path-separator=/
set grepformat=%f:%l:%c:%m

" Typos
command! -nargs=? -complete=file Typos cexpr system('typos --format brief <args>')
" Ruff
command! -nargs=1 -complete=file Ruff cexpr system('uv tool run ruff check --output-format concise <args>')
" Ty
command! -nargs=1 -complete=file Ty cexpr system('uv tool run ty check --output-format concise <args>')
" error[invalid-assignment] main.py:2:5: Object
set errorformat^=%t%.%#\ %f:%l:%c:\ %m
" check trailing whitespace
command! -nargs=1 -complete=file TrailingWhitespace grep "[\ 　\t]+$" <args>
command! -nargs=1 -complete=file Twh TrailingWhitespace <args>
" markdownlint-cli2
command! -nargs=? -complete=file Markdownlint cexpr system('markdownlint-cli2 <args>')
command! -nargs=? -complete=file Mdl Markdownlint <args>
set errorformat^=%f:%l\ %m
set errorformat^=%f:%l:%c\ %m
" todo.txt
command! -nargs=0 Due cgetexpr system('rg "^[^x].*\sdue:" -nHP -g *.txt|perl -lane "{print $F[-1].\" \".$F[0]}"|sort|perl -lane "print $F[1],$F[0]"')
command! -nargs=1 Pro cgetexpr system('rg "^[^x].*\s\+<args> -nHP -g *.txt')

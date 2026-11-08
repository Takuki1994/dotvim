" TODO: init.vim が567行と肥大化 → keymaps.vim, commands.vim, functions.vim に分割検討
set shell=cmd

" let g:nvim_home=<nvimフォルダへのパス>
" let g:disable_auto_theme_change=0
source ~\.config\nvim\.env

" spell settings
syntax on
set spell
set spelllang=en_us,cjk
set spellcapcheck=
set spellsuggest=best,5
set spelloptions=camel,noplainbuffer

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
" todo.txt 回りの処理
" @また+の次に続きスペースまでの文字列をバッファから抽出するcompletefunc
function! TodoComplete(findstart, base)
  if a:findstart
      return matchstrpos(strpart(getline('.'),0,col('.')), '\s[+@]\zs\S*$')[1]
  endif
  " カーソルの1つ前の文字が@または+でない場合は空のリストを返す
  let l:cur_line = getline('.')
  let l:cur_col = col('.') - 1
  if l:cur_col <= 0 || (l:cur_line[l:cur_col - 1] !=# '@' && l:cur_line[l:cur_col - 1] !=# '+')
    return []
  endif
  " カーソルの1つ前の文字列が\s@の場合はバッファ内の@の後からスペースまたは行末までの文字列を抽出する
  " カーソルの1つ前の文字列が\s+の場合はバッファ内の+の後からスペースまたは行末までの文字列を抽出する
  if l:cur_line[l:cur_col - 1] ==# '@'
    let l:pattern = '\W@\zs\S\+'
  else
    let l:pattern = '\W+\zs\S\+'
  endif
  let l:matches = []
  for l:line in getline(1, '$')
    let l:matchlist = matchlist(l:line, l:pattern)
    if !empty(l:matchlist)
      call add(l:matches, l:matchlist[0])
    endif
  endfor
  if a:base !=# '' && executable('cmigemo') && exists('$MIGEMO_DICT')
    " cmigemoが使える場合はcmigemoでフィルターをかける
    let l:regex = system('cmigemo -d "' . $MIGEMO_DICT . '" -w "' . a:base . '" -v -n')
    return filter(uniq(sort(l:matches)), {_, val -> val =~# l:regex })
  else
    " 重複を削除してリストを返す
    return uniq(sort(l:matches))
  endif
endfunction

" todo.txtのプロジェクトタスクとサブタスクをfoldする関数
function! TodoFold() abort
  if !exists('s:project_name')
    let s:project_name = ''
  endif
  let l:line = getline(v:lnum)
  if l:line =~ '\s+\S\+' && l:line =~ '\sest:\d\+\(\s\|$\)'
    let l:project_name = matchstr(l:line, '\s+\zs\S\+')
    " 前回のプロジェクト名と一致する場合は折り畳みを継続する
    if l:project_name ==# s:project_name
      return '1'
    " 前回のプロジェクト名と一致しない場合は新しく折り畳みを開始する
    else
      let s:project_name = l:project_name
      return '>1'
    endif
  elseif l:line =~ '\s+\S\+'
    " サブタスクの場合は前回のプロジェクト名と一致する場合のみ折り畳みを継続する
    let l:project_name = matchstr(l:line, '\s+\zs\S\+')
    " 前回のプロジェクト名と一致する場合は折り畳みを継続する
    if l:project_name ==# s:project_name
      return '1'
    " 前回のプロジェクト名と一致しない場合は折り畳まない
    else
      let s:project_name = ''
      return '0'
    endif
  else
    let s:project_name = ''
    return '0'
  endif
endfunction

function! Date2Time(date) abort
  if a:date == ''
    return 0
  end
  let l:year = matchstr(a:date, '^\d\{4\}')
  let l:month = matchstr(a:date, '^\d\{4\}-\zs\d\{2\}')
  let l:day = matchstr(a:date, '\d\{2\}$')
  return luaeval('os.time({year=' . l:year . ', month=' . l:month
        \ . ', day=' . l:day . ', hour=0, min=0, sec=0})')
endfunction

" foldtext用関数
function! TodoFoldText() abort
  " 先頭行からプロジェクト名を取得する
  let l:line = getline(v:foldstart)
  let l:project_name = matchstr(l:line, '\s+\zs\S\+')
  let l:est_num = str2nr(matchstr(l:line, '\sest:\zs\d\+'))
  " プロジェクトタスクが完了済みの場合はサブタスクのカウントは行わない
  if l:line =~ '^x\s'
    return printf(" 完了 󰐱 %2d  %s", l:est_num, l:project_name)
  endif
  let l:project_due_date = matchstr(l:line, '\sdue:\zs\d\{4\}-\d\{2\}-\d\{2\}')
  let l:near_due_date = l:project_due_date
  if l:project_due_date ==# ''
    let l:project_due_date = '···未定···'
  endif
  let l:updated_date = matchstr(l:line, '^\(\|(\a)\s\|^x\s\)\zs\d\{4\}-\d\{2\}-\d\{2\}')
  " サブタスクの総数、完了済みのサブタスクの数をカウントする
  " \s@reference\(\s\|$\)を含むサブタスクは資料として別にカウントする
  let l:subtask_total = 0
  let l:subtask_done = 0
  let l:reference_count = 0
  if v:foldstart != v:foldend
    for l:num in range(v:foldstart + 1, v:foldend)
      let l:subtask_line = getline(l:num)
      if l:subtask_line =~ '\s@reference\(\s\|$\)'
        let l:reference_count += 1
      else
        let l:subtask_total += 1
        if l:subtask_line =~ '^x\s'
          let l:subtask_done += 1
        endif
      endif
      let l:date = matchstr(l:subtask_line, '^\(\|(\a)\s\|^x\s\)\zs\d\{4\}-\d\{2\}-\d\{2\}')
      let l:due_date = matchstr(l:subtask_line, '\sdue:\zs\d\{4\}-\d\{2\}-\d\{2\}')
      if Date2Time(l:date) > Date2Time(l:updated_date)
          let l:updated_date = l:date
      endif
      if Date2Time(l:near_due_date) == 0
                  \ || Date2Time(l:due_date) != 0 && Date2Time(l:due_date) < Date2Time(l:near_due_date)
          let l:near_due_date = l:due_date
      endif
    endfor
  endif
  " 現在時刻と比較して日付を計算する
  let l:now_time = localtime()
  let l:near_due_days = (Date2Time(l:near_due_date) - l:now_time) / 86400
  let l:updated_days = (l:now_time - Date2Time(l:updated_date)) / 86400
  let l:near_due_text = ''
  let l:header_icon = '󰄷 '
  if l:updated_days >= 14
      " 更新日が14日以上経過している場合はアイコンを変更する
      let l:header_icon = '󰒲 '
  elseif (Date2Time(l:near_due_date) - l:now_time) < 0 && Date2Time(l:near_due_date) != 0
      " 期限当日
      let l:header_icon = ' '
      let l:near_due_text = '  ' . l:near_due_date
  elseif l:near_due_days < 7 && Date2Time(l:near_due_date) != 0
      " 期限が1週間内
      let l:header_icon = ' '
      let l:near_due_text = '  ' . l:near_due_date
  elseif subtask_total == 0
      let l:header_icon = '󱋭 '
  elseif subtask_total == subtask_done
      let l:header_icon = '󰄹 '
  else
      let l:header_icon = '󰄷 '
  endif
  " 折り畳みの表示形式を返す
  return printf("%s%d/%d  %2d 󰐱 %2d 󰚰 %s  %s  %s%s",
        \ l:header_icon,
        \ l:subtask_done, l:subtask_total, l:reference_count,
        \ l:est_num, l:updated_date, l:project_due_date, l:project_name,
        \ l:near_due_text)
endfunction

function! TaskDone() abort
  let l:line = getline('.')
  if l:line =~ '^x\s'
    " 既に完了済みの場合はなにもしない
    return
  endif
  " 行頭に優先度がある場合は削除する
  if l:line =~ '^(\a)\s'
    normal! 0da(x
  endif
  " 行頭にxと完了日を挿入する
  let l:done_date = strftime('%Y-%m-%d')
  execute 'normal! 0i' . 'x ' . l:done_date . ' '
endfunction

augroup todo
  autocmd!
  autocmd BufNewFile,BufRead [tT]odo.txt,[iI]nbox.txt,[dD]one.txt
        \ setlocal filetype=todo 
  autocmd FileType todo setlocal completefunc=TodoComplete
                                \ foldmethod=expr foldexpr=TodoFold()
                                \ foldtext=TodoFoldText()
                                \ foldminlines=0
                                \ nofixendofline
  autocmd FileType todo nnoremap <silent> <Leader><Leader>x :call TaskDone()<CR>
augroup END
" laststatus=3はNeoVim限定の設定
set laststatus=3

" keymap
inoremap <Leader><Leader>date <C-R>=strftime('%Y-%m-%d')<CR>
cnoremap <Leader><Leader>date <C-R>=strftime('%Y-%m-%d')<CR>
inoremap <Leader><Leader>time <C-R>=strftime('%Y-%m-%d_%H-%M')<CR>
cnoremap <Leader><Leader>time <C-R>=strftime('%Y-%m-%d_%H-%M')<CR>
let scratch_cmd = ':setlocal buftype=nofile bufhidden=hide noswapfile|:file memo_'
nnoremap <silent> <expr> <Leader>se ':ene\|' . scratch_cmd
      \. strftime('%Y%m%d%H%M%S') . '<CR>'
nnoremap <silent> <expr> <Leader>st ':tabe\|' . scratch_cmd
      \. strftime('%Y%m%d%H%M%S') . '<CR>'
nnoremap <silent> <expr> <Leader>sv ':vs\|:ene\|' . scratch_cmd
      \. strftime('%Y%m%d%H%M%S') . '<CR>'
nnoremap <silent> <expr> <Leader>ss ':sp\|:ene\|' . scratch_cmd
      \. strftime('%Y%m%d%H%M%S') . '<CR>'
nnoremap <silent> <C-k> <C-w>w
if executable('pwsh')
  nnoremap <silent> <expr> <Leader>te ':terminal pwsh<CR>\|:file pwsh_'
      \. strftime('%Y%m%d%H%M%S') . '<CR>'
  nnoremap <silent> <expr> <Leader>tt ':tabe\|:terminal pwsh<CR>\|:file pwsh_'
      \. strftime('%Y%m%d%H%M%S') . '<CR>'
  nnoremap <silent> <expr> <Leader>tv ':vs\|:terminal pwsh<CR>\|:file pwsh_'
      \. strftime('%Y%m%d%H%M%S') . '<CR>'
else
  nnoremap <silent> <expr> <Leader>tt ':tabe\|:terminal<CR>\|:file cmd_'
      \. strftime('%Y%m%d%H%M%S') . '<CR>'
  nnoremap <silent> <expr> <Leader>tv ':vs\|:terminal<CR>\|:file cmd_'
      \. strftime('%Y%m%d%H%M%S') . '<CR>'
endif


" plugin
" TODO: .env.sample ファイルを作成してテンプレート提供（現在.envがgitignore）
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

if executable('typos') && executable('perl')
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
endif

" findfunc
function! s:FindFunc(cmdarg, complete)
  if filereadable(a:cmdarg)
    " 入力した文字列が存在するファイルパスの場合はそのまま返す
    return [a:cmdarg]
  endif
  " rg がある場合はrgで検索する
  if executable('rg')
    let l:result = systemlist('rg --files --hidden --glob "!.git/*"')
          \->mapnew({idx, val-> val->substitute('\r', '', 'g')})
  else
    let l:result = globpath('.', '**', 0, 1)
          \->filter({k,v -> !isdirectory(v)})
          \->mapnew({k,v -> v->substitute('^\.[\/\\]','','')})
  endif
  return l:result->matchfuzzy(a:cmdarg)
endfunction
set wildignore=.git/**
set findfunc=s:FindFunc

if executable('typos')
  function s:SpellTypos()
    let json_str = system("echo " . v:val . " | typos - --format json")->substitute('\([:,]\)', '\1 ', 'g')
    let result = []
    for item in json_decode(json_str).corrections
      call add(result, [item, 0])
    endfor

    return result
  endfunction
  set spellsuggest=expr:s:SpellTypos()
endif

if executable('copilot')
  " `copilot`という名前のterminalをvsplitで起動する。
  " すでに同名のbufferが存在する場合はメッセージを表示して処理を中断する
  function! s:OpenCopilotTerminal()
    let l:term_name = 'copilot'
    let l:term_bufnr = bufexists(l:term_name) ? bufnr(l:term_name) : -1
    if l:term_bufnr == -1
      " ターミナルが存在しない場合は新規作成
      execute 'vsplit | terminal cmd /c copilot --banner --model auto'
      execute 'file ' . l:term_name
    else
      " ターミナルが存在する場合はメッセージを表示して処理を中断
      echohl ErrorMsg
      echomsg 'Copilot terminal already exists.'
      echohl None
      return
    endif
    " insertモードに入る
    startinsert
  endfunction
  " `copilot review`という名前のterminalをvsplitで起動する。
  " すでに同名のbufferが存在する場合はメッセージを表示する処理を中断する
  function! s:OpenCopilotReviewTerminal()
    let l:term_name = 'copilot_review'
    let l:term_bufnr = bufexists(l:term_name) ? bufnr(l:term_name) : -1
    if l:term_bufnr != -1
      " ターミナルが存在する場合はメッセージを表示して処理を中断
      echohl ErrorMsg
      echomsg 'Copilot review terminal already exists.'
      echohl None
      return
    endif
    " 新規作成して表示
    " レビューの指示は文字化け対策で英語、出力を日本語にする
    execute 'vsplit | terminal cmd /c copilot --model auto -p "review only the staged files in japanese"'
    execute 'file ' . l:term_name
    " insertモードに入る
    startinsert
  endfunction
  " 再レビュー用
  function! s:OpenCopilotRereviewTerminal()
    let l:term_name = 'copilot_rereview'
    let l:term_bufnr = bufexists(l:term_name) ? bufnr(l:term_name) : -1
    if l:term_bufnr != -1
      " ターミナルが存在する場合はメッセージを表示して処理を中断
      echohl ErrorMsg
      echomsg 'Copilot rereview terminal already exists.'
      echohl None
      return
    endif
    " 新規作成して表示
    " レビューの指示は文字化け対策で英語、出力を日本語にする
    " 直前のレビューから繰り返し実行する想定で、--continueオプションを付与する
    execute 'vsplit | terminal cmd /c copilot --continue --model auto -p "review only the staged files in japanese"'
    execute 'file ' . l:term_name
    " insertモードに入る
    startinsert
  endfunction

  nnoremap <silent> <Leader>cc :call <SID>OpenCopilotTerminal()<CR>
  nnoremap <silent> <Leader>cr :call <SID>OpenCopilotReviewTerminal()<CR>
  nnoremap <silent> <Leader>cR :call <SID>OpenCopilotRereviewTerminal()<CR>
endif

if executable('git')
  augroup git_commit
    autocmd!
    autocmd FileType gitcommit setlocal fileencoding=utf-8
  augroup END
  " a:nameという名前のterminalをa:cmdを実行してa:split_strで起動する。
  " すでに同名のterminalが存在する場合は再利用してa:split_strで表示する。
  function! s:OpenCommandTerminal(name, cmd, split_str)
    " git rev-parse --is-inside-work-treeで現在のディレクトリが
    " gitリポジトリ内かどうかを確認し、リポジトリ内でない場合は処理を中断する
    if system('git rev-parse --is-inside-work-tree 2>&1') !~ 'true'
      echo 'Not inside a git repository.'
      return
    endif
    let l:term_bufnr = bufexists('term://' . a:name) ? bufnr('term://' . a:name) : -1
    if l:term_bufnr == -1
      " ターミナルが存在しない場合は新規作成
      execute a:split_str . ' | terminal cmd /c ' . a:cmd
      execute 'file ' . a:name
    else
      " ターミナルが存在する場合は再利用して表示
      execute a:split_str . ' | buffer ' . l:term_bufnr
    endif
    " insertモードに入る
    startinsert
  endfunction

  function! s:GitRemoteComplete(arglead, cmdline, cursorpos)
    let l:remotes = systemlist('git remote')
          \->mapnew({idx, val-> val->substitute('\r', '', 'g')})
    return l:remotes->matchfuzzy(a:arglead)
  endfunction
  command! -nargs=1 -complete=customlist,s:GitRemoteComplete GitPushTo
        \ call <SID>OpenCommandTerminal('git_push', 'git push ' . '<args>', ':vs')

  function! s:GitLocalBranchComplete(arglead, cmdline, cursorpos)
    let l:branches = systemlist('git branch -l --format="%(refname:short)"')
          \->mapnew({idx, val-> val->substitute('\r', '', 'g')})
    return l:branches->matchfuzzy(a:arglead)
  endfunction
  function! s:GitRemoteBranchComplete(arglead, cmdline, cursorpos)
    let l:branches = systemlist('git branch -r --format="%(refname)"')
          \->mapnew({idx, val-> val->substitute('^refs\/remotes\/', '', '')})
          \->mapnew({idx, val-> val->substitute('\r', '', 'g')})
    return l:branches->matchfuzzy(a:arglead)
  endfunction
  function! s:GitAllBranchComplete(arglead, cmdline, cursorpos)
    let l:branches = systemlist('git branch -a --format="%(refname)"')
          \->mapnew({idx, val-> val->substitute('^refs\/remotes\/', '', '')})
          \->mapnew({idx, val-> val->substitute('^refs\/heads\/', '', '')})
          \->mapnew({idx, val-> val->substitute('\r', '', 'g')})
    return l:branches->matchfuzzy(a:arglead)
  endfunction
  " ブランチ名を使用するgitコマンド
  command! -nargs=1 -complete=customlist,s:GitLocalBranchComplete GitSwitch
        \ call <SID>OpenCommandTerminal('git_checkout', 'git switch ' . '<args>', ':vs')
  command! -nargs=1 -complete=customlist,s:GitRemoteBranchComplete GitSwitchRemote
        \ call <SID>OpenCommandTerminal('git_checkout', 'git switch -c ' . '<args>', ':vs')
  command! -nargs=1 -complete=customlist,s:GitAllBranchComplete GitResetHard
        \ call <SID>OpenCommandTerminal('git_reset', 'git reset --hard ' . '<args>', ':vs')
  command! -nargs=1 -complete=customlist,s:GitAllBranchComplete GitResetSoft
        \ call <SID>OpenCommandTerminal('git_reset', 'git reset --soft ' . '<args>', ':vs')

  function! s:SerchFileComplete(arglead, cmdline, cursorpos)
    if filereadable(a:arglead)
      " 入力した文字列が存在するファイルパスの場合はそのまま返す
      return [a:arglead]
    endif
    if executable('rg')
      let l:result = systemlist('rg --files')
          \->filter({k,v -> !isdirectory(v)})
          \->mapnew({k,v -> v->substitute('^\.[\/\\]','','')})
    else
      let l:result = globpath('.', '**', 0, 1)
            \->filter({k,v -> !isdirectory(v)})
            \->mapnew({k,v -> v->substitute('^\.[\/\\]','','')})
    endif
    return l:result->matchfuzzy(a:arglead)
  endfunction
  command! -nargs=1 -complete=customlist,s:SerchFileComplete GitRestore
        \ call <SID>OpenCommandTerminal('git_restore', 'git restore ' . '<args>', ':vs')
  command! -nargs=1 -complete=customlist,s:SerchFileComplete GitRestoreStaged
        \ call <SID>OpenCommandTerminal('git_restore_staged', 'git restore --staged ' . '<args>', ':vs')

  nnoremap <silent> <Leader>gs :call <SID>OpenCommandTerminal('git_status', 'git status', ':vs')<CR>
  nnoremap <silent> <Leader>gt :call <SID>OpenCommandTerminal('git_tree', 'git log --graph --format="\%x09\%C(cyan)\%h\%Creset \%ar\%x09\%C(green bold)\%an\%Creset \%C(magenta bold)\%d\%Creset \%s', string(&lines*0.75) . 'sp')<CR>
  nnoremap <silent> <Leader>gT :call <SID>OpenCommandTerminal('git_tree', 'git log --graph --all --format="\%x09\%C(cyan)\%h\%Creset \%ar\%x09\%C(green bold)\%an\%Creset \%C(magenta bold)\%d\%Creset \%s', string(&lines*0.75) . 'sp')<CR>
  nnoremap <silent> <Leader>gl :call <SID>OpenCommandTerminal('git_log', 'git log', string(&lines*0.75) . 'sp')<CR>
  nnoremap <silent> <Leader>gL :call <SID>OpenCommandTerminal('git_log', 'git log -p', string(&lines*0.75) . 'sp')<CR>
  nnoremap <silent> <Leader>gd :call <SID>OpenCommandTerminal('git_diff', 'git diff', string(&lines*0.75) . 'sp')<CR>
  nnoremap <silent> <Leader>gD :call <SID>OpenCommandTerminal('git_diff', 'git diff --cached', string(&lines*0.75) . 'sp')<CR>
  nnoremap <silent> <Leader>ga :call <SID>OpenCommandTerminal('git_add', 'git add -p', string(&lines*0.75) . 'sp')<CR>
  nnoremap <silent> <Leader>gA :!git add .<CR>
  nnoremap <silent> <Leader>gc :call <SID>OpenCommandTerminal('git_commit', 'git commit -v', ':vs')<CR>
  nnoremap <silent> <Leader>gC :call <SID>OpenCommandTerminal('git_commit_ammend', 'git commit -v --amend', ':vs')<CR>
  nnoremap <silent> <Leader>gf :call <SID>OpenCommandTerminal('git_fetch', 'git fetch', ':vs')<CR>
  nnoremap <silent> <Leader>gb :call <SID>OpenCommandTerminal('git_blame', 'git blame %', string(&lines*0.75) . 'sp')<CR>
  nnoremap <silent> <Leader>gp :call <SID>OpenCommandTerminal('git_pull', 'git pull', ':vs')<CR>
  nnoremap <Leader>GP :GitPushTo<Space>
  nnoremap <Leader>Gb :GitSwitch<Space>
  nnoremap <Leader>GS :GitSwitchRemote<Space>
  nnoremap <Leader>Gr :GitResetHard<Space>
  nnoremap <Leader>GR :GitResetSoft<Space>
  nnoremap <Leader>gr :GitRestore<Space>
  nnoremap <Leader>gR :GitRestoreStaged<Space>
endif

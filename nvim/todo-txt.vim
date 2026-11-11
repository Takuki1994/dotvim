" todo.txt 回りの処理
" catタグ,@また+の次に続きスペースまでの文字列をバッファから抽出するcompletefunc
function! TodoComplete(findstart, base)
  if a:findstart
    return matchstrpos(strpart(getline('.'),0,col('.')), '\s\(cat:\|[+@]\)\zs\S*$')[1]
  endif
  " カーソルの1つ前の文字が@または+でない場合は空のリストを返す
  let l:cur_line = getline('.')
  let l:cur_col = col('.') - 1
  if l:cur_col <= 0 || (l:cur_line[l:cur_col - 1] !=# '@' && l:cur_line[l:cur_col - 1] !=# '+'
        \ && l:cur_line[l:cur_col - 1] !=# ':')
    return []
  endif
  " カーソルの1つ前の文字列が\s@の場合はバッファ内の@の後からスペースまたは行末までの文字列を抽出する
  " カーソルの1つ前の文字列が\s+の場合はバッファ内の+の後からスペースまたは行末までの文字列を抽出する
  if l:cur_line[l:cur_col - 1] ==# '@'
    let l:pattern = '\W@\zs\S\+'
  elseif l:cur_line[l:cur_col - 1] ==# '+'
    let l:pattern = '\W+\zs\S\+'
  else
    let l:pattern = '\Wcat:\zs\S\+'
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
      let l:due_date = matchstr(l:subtask_line, '^[^x].*\sdue:\zs\d\{4\}-\d\{2\}-\d\{2\}')
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
  " todo2icsは自作コマンド
  if executable('todo2ics')
    autocmd FileType todo nnoremap <silent> <Leader><Leader>caL :%!todo2ics %:p 2>nul<CR>
    autocmd FileType todo nnoremap <silent> <Leader><Leader>cal :!todo2ics --dry %:p<CR>
    autocmd FileType todo nnoremap <silent> <Leader><Leader>gx  :!explorer %:p:h\ics<CR>
  endif
augroup END

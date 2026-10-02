" File:        todo.txt.vim
" Description: Todo.txt syntax settings
" Author:      David Beniamine <David@Beniamine.net>,Leandro Freitas <freitass@gmail.com>
" License:     Vim license
" Website:     http://github.com/dbeniamine/todo.txt-vim
" Version:     0.7.2

if exists("b:current_syntax")
    finish
endif

syntax  match  TodoDone       '^[xX]\s.\+$'               contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityA  '^([aA])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityB  '^([bB])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityC  '^([cC])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityD  '^([dD])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityE  '^([eE])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityF  '^([fF])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityG  '^([gG])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityH  '^([hH])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityI  '^([iI])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityJ  '^([jJ])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityK  '^([kK])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityL  '^([lL])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityM  '^([mM])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityN  '^([nN])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityO  '^([oO])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityP  '^([pP])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityQ  '^([qQ])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityR  '^([rR])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityS  '^([sS])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityT  '^([tT])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityU  '^([uU])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityV  '^([vV])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityW  '^([wW])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityX  '^([xX])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityY  '^([yY])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoPriorityZ  '^([zZ])\s.\+$'             contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match  TodoDate       '\d\{2,4\}-\d\{2\}-\d\{2\}' contains=NONE
syntax  match  TodoKey        '\S*\S:\S\S*'                   contains=TodoDate
syntax  match  TodoProject    '\(^\|\W\)+[^[:blank:]]\+'  contains=NONE
syntax  match  TodoContext    '\(^\|\W\)@[^[:blank:]]\+'  contains=NONE

let b:current_date = strftime("%Y%m%d")
let b:threshold_regex = '^[^x].*\st:\('
let b:pass_due_regex = ''
let b:y3=str2nr(strcharpart(b:current_date, 2, 1))
let b:thr=string(b:y3<9?b:y3+1:0)
let b:threshold_regex=b:threshold_regex.'20['.b:thr.'-9]\d-\d\{2\}-\d\{2\}'
if b:y3>0
  let b:due=string(b:y3-1)
  let b:pass_due_regex=b:pass_due_regex.'20[0-'.b:due.']\d-\d\{2\}-\d\{2\}'
endif
let b:y4=str2nr(strcharpart(b:current_date, 3, 1))
let b:thr=string(b:y4<9?b:y4+1:0)
let b:threshold_regex=b:threshold_regex.'\|20'.string(b:y3).'['.b:thr.'-9]-\d\{2\}-\d\{2\}'
if b:y4>0
  let b:due=string(b:y4-1)
  let b:pass_due_regex=b:pass_due_regex.(len(b:pass_due_regex)>0?'\|':'')
  let b:pass_due_regex=b:pass_due_regex.'20'.string(b:y3).'[0-'.b:due.']-\d\{2\}-\d\{2\}'
endif
let b:m1=str2nr(strcharpart(b:current_date, 4, 1))
if b:m1==0
  let b:threshold_regex=b:threshold_regex.'\|20'.string(b:y3).string(b:y4).'-1\d-\d\{2\}'
endif
if b:m1>0
  let b:due=string(b:m1-1)
  let b:pass_due_regex=b:pass_due_regex.(len(b:pass_due_regex)>0?'\|':'')
  let b:pass_due_regex=b:pass_due_regex.'20'.string(b:y3).string(b:y4).'-0[1-9]-\d\{2\}'
endif
let b:m2=str2nr(strcharpart(b:current_date, 5, 1))
let b:thr=string(b:m2<9?b:m2+1:0)
let b:threshold_regex=b:threshold_regex.'\|20'.string(b:y3).string(b:y4).'-'.string(b:m1).'['.b:thr.'-9]-\d\{2\}'
if b:m2>0
  let b:due=string(b:m2-1)
  let b:pass_due_regex=b:pass_due_regex.(len(b:pass_due_regex)>0?'\|':'')
  let b:pass_due_regex=b:pass_due_regex.'20'.string(b:y3).string(b:y4).'-'.string(b:m1).'[0-'.b:due.']-\d\{2\}'
endif
let b:d1=str2nr(strcharpart(b:current_date, 6, 1))
let b:thr=string(b:d1<3?b:d1+1:0)
let b:threshold_regex=b:threshold_regex.'\|20'.string(b:y3).string(b:y4).'-'.string(b:m1).string(b:m2).'-['.b:thr.'-3]\d'
if b:d1>0
  let b:due=string(b:d1-1)
  let b:pass_due_regex=b:pass_due_regex.(len(b:pass_due_regex)>0?'\|':'')
  let b:pass_due_regex=b:pass_due_regex.'20'.string(b:y3).string(b:y4).'-'.string(b:m1).string(b:m2).'-[0-'.b:due.']\d'
endif
let b:d2=str2nr(strcharpart(b:current_date, 7, 1))
let b:thr=string(b:d2<9?b:d2+1:0)
let b:threshold_regex=b:threshold_regex.'\|20'.string(b:y3).string(b:y4).'-'.string(b:m1).string(b:m2).'-'.string(b:d1).'['.b:thr.'-9]'
if b:d2>0
  let b:due=string(b:d2)
  let b:pass_due_regex=b:pass_due_regex.(len(b:pass_due_regex)>0?'\|':'')
  let b:pass_due_regex=b:pass_due_regex.'20'.string(b:y3).string(b:y4).'-'.string(b:m1).string(b:m2).'-'.string(b:d1).'[0-'.b:due.']'
endif
let b:threshold_regex=b:threshold_regex.'\)\s*.*$'
let b:pass_due_regex='^[^x].*\sdue:\('.b:pass_due_regex.'\)\s*.*$'
execute("syntax match TodoThreshold '"
      \.b:threshold_regex
      \."' contains=TodoKey,TodoDate,TodoProject,TodoContext")
execute("syntax match TodoPassDue '"
      \.b:pass_due_regex
      \."' contains=TodoKey,TodoDate,TodoProject,TodoContext")

" Other priority colours might be defined by the user
highlight  default  link  TodoKey        Special
highlight  default  link  TodoDone       Comment
highlight  default  link  TodoPriorityA  Identifier
highlight  default  link  TodoPriorityB  statement
highlight  default  link  TodoPriorityC  type
highlight  default  link  TodoPriorityD  Label
highlight  default  link  TodoDate       PreProc
highlight  default  link  TodoProject    Special
highlight  default  link  TodoContext    Special
highlight  default  link  TodoThreshold  EndOfBuffer
highlight  default  link  TodoPassDue    ErrorMsg

let b:current_syntax = "todo"

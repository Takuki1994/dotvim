command! -nargs=? Due lgetexpr system('rg "^[^x][A-C].*\sdue:" -nHP --crlf -g *.txt <args>|perl -lane "@G=split(/:/,$F[0]);$task{$_}=$F[-1].$G[-1].$F[1];END{print for sort {$task{$a} cmp $task{$b}} keys %task}"')
command! -nargs=1 Pro lgetexpr system('rg "^[^x][A-C].*\s\+<args>" -nHP --crlf -g *.txt')
command! -nargs=? Done lgrep ^x\s -g !done.txt <args>
command! -nargs=? Remember lgetexpr system('rg "^[^x][A-C](?!.*\sdue:).*$" -nHP --crlf -g *.txt <args>|perl -lane "@G=split(/:/,$F[0]);$task{$_}=$F[1].$G[-1];END{print for sort {$task{$a} cmp $task{$b}} keys %task}"')


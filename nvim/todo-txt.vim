command! -nargs=? Due lgetexpr system('rg "^[^x][A-C].*\sdue:" -nHP --crlf -g *.txt <args>|perl -lane "$due=$1 if /^.*(due:[0-9\-]+)\s*.*/;$priority=$1 if $F[0]=~/^.*:(\([A-C]\))$/;$task{$_}=$due.$priority.$F[1];END{print for sort {$task{$a} cmp $task{$b}} keys %task}"')
command! -nargs=1 Pro lgetexpr system('rg "^[^x][A-C].*\s\+<args>" -nHP --crlf -g *.txt')
command! -nargs=? Done lgrep ^x\s -g !done.txt <args>
command! -nargs=? Remember lgetexpr system('rg "^[^x][A-C](?!.*\sdue:).*$" -nHP --crlf -g *.txt <args>|perl -lane "$priority=$1 if $F[0]=~/^.*:(\([A-C]\))$/;$task{$_}=$F[1].$priority;END{print for sort {$task{$a} cmp $task{$b}} keys %task}"')
command! -nargs=? Context lgetexpr system('rg "^[^x][A-C].*\s@<args>.*$" -nHP --crlf -g *.txt|perl -lane "$priority=$1 if $F[0]=~/^.*:(\([A-C]\))$/;$context=$1 if /.*\s(\@[^\s]+)\s*/;$task{$_}=$context.$priority.$F[1];END{print for sort {$task{$a} cmp $task{$b}} keys %task}"')


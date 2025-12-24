set shell := ["pwsh", "-c"]

default:
	@just --list

deploy win:
	@cp ./nvim $env:USERPROFILE/AppData/Local/ -Recurse -Force

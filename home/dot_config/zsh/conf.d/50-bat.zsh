# Pipe --help through bat.

alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

alias bathelp='bat --plain --language=help'
help() {
  "$@" --help 2>&1 | bathelp
}

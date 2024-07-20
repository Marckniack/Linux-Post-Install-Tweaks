#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

PS1='[\[\e[1m\]\h\[\e[0m\]] \[\e[2;3m\]\w\n\[\e[0m\]\$ '

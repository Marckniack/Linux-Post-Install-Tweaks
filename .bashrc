#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# ORIGINAL
#PS1='[\u@\h \W]\$ '

# NEW
PS1='[\[\e[1m\]\h\[\e[0m\]] \[\e[2;3m\]\w\n\[\e[0m\]\$ '

# Custom aliases
alias Archbox="distrobox enter -n archbox -a '--env XDG_CURRENT_DESKTOP=X-Generic --env LANG=en_US.UTF-8 --env LC_ALL=en_US.UTF-8' -nw"

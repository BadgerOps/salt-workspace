base_packages:
  - vim
  - screen

bash:
  profile: |
    shopt -s checkwinsize
    shopt -s histappend
    unset MAILCHECK
    export EDITOR=vim
    export PATH=$PATH:~/.bin
    export HISTSIZE=10000000
    export HISTCONTROL=ignoredups
    export HISTTIMEFORMAT='%F %T '
    export PROMPT_COMMAND='history -a'
    export LSCOLORS='Gxfxcxdxdxegedabagacad'
    export PS1='\[\033[01;35m\]\u@\H\[\033[01;34m\] \W \$\[\033[00m\] '
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'

motd:
  content: |

           #########################################################################################################
           #                                                                                                       #
           #            This host is managed by Salt. Configuration changes made directly will be lost.            #
           #                                                                                                       #
           #########################################################################################################

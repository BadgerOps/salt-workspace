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

consul:
  version: 0.7.5
  hash: 40ce7175535551882ecdff21fdd276cef6eaab96be8a8260e0599fadb6f1f5b8
  service: True
  {% if salt['grains.get']('virtual') == 'VirtualBox' %}
  config:
    datacenter: VAGRANT
    {% if grains['nodename'] == 'saltmaster' %}
    server: True
    bootstrap: True
    {% else %}
    server: False
    {% endif %}
    bind_addr: {{ grains['ip4_interfaces']['enp0s8'][0] }}
    start_join:
      - saltmaster
    {% endif %}

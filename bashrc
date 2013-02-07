# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
# ** matches all files and zero or more directories
shopt -s globstar
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'

# custom stuff
set -o vi

# Magical prompts

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm) color_prompt=yes;;
    xterm-color) color_prompt=yes;;
esac

function parse_git_branch {
    git_status="$(git status 2> /dev/null)"
    branch_pattern="^# On branch ([^${IFS}]*)"
    remote_pattern="# Your branch is (.*) of"
    diverge_pattern="# Your branch and (.*) have diverged"
    if [[ ! ${git_status} =~ "working directory clean" ]]; then
        state="${RED}*"
    fi

    if [[ ${git_status} =~ ${remote_pattern} ]]; then
        if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
            remote="↑"
        else
            remote="↓"
        fi
    fi
    if [[ ${git_status} =~ ${diverge_pattern} ]]; then
        remote="↕"
    fi
    if [[ ${git_status} =~ ${branch_pattern} ]]; then
        branch=${BASH_REMATCH[1]}
        echo " ${YELLOW}(${branch})${remote}${state}${COLOR_NONE}"
    fi
}

EXIT_CODE[0]='SUCCESS'
EXIT_CODE[1]='FAIL'
EXIT_CODE[2]='MISUSE'

# extract system defined exit statuses from /usr/include/sysexits.h
. <(grep "#define EX_[^_]" /usr/include/sysexits.h | awk '{ print "EXIT_CODE[" $3 "]="$2 }')

EXIT_CODE[127]='CMD_NOT_FOUND'
EXIT_CODE[128]='INVALID_EXIT'
EXIT_CODE[129]='KILL_1'
EXIT_CODE[130]='CTRL_C'
EXIT_CODE[131]='KILL_3'
EXIT_CODE[132]='KILL_4'
EXIT_CODE[133]='KILL_5'
EXIT_CODE[134]='KILL_6'
EXIT_CODE[135]='KILL_7'
EXIT_CODE[136]='KILL_8'
EXIT_CODE[137]='KILL_9'
EXIT_CODE[255]='EXIT_OUT_OF_RANGE'

function parse_exit_status {
    if [[ $1 != 0 ]]; then
        if [[ -n ${EXIT_CODE[$1]} ]];
        then
            echo " ${RED}($1:${EXIT_CODE[$1]})${COLOR_NONE}"
        else
            echo " ${RED}($1)${COLOR_NONE}"
        fi
    else
        echo "${COLOR_NONE}"
    fi
}

function prompt_func()
{
    EXIT_STATUS=$?
    PS1="${GREEN}\\u${COLOR_NONE}@${RED}\\h${COLOR_NONE}:${WHITE}\\w$(parse_git_branch)$(parse_exit_status ${EXIT_STATUS})\\$ "
}

if [[ -n $color_prompt ]]; then
    RED="\[\033[0;31m\]"
    YELLOW="\[\033[0;33m\]"
    GREEN="\[\033[0;32m\]"
    BLUE="\[\033[0;34m\]"
    LIGHT_RED="\[\033[1;31m\]"
    LIGHT_GREEN="\[\033[1;32m\]"
    WHITE="\[\033[1;37m\]"
    LIGHT_GRAY="\[\033[0;37m\]"
    COLOR_NONE="\[\e[0m\]"
fi

unset color_prompt force_color_prompt

PROMPT_COMMAND=prompt_func
#!/bin/bash

###########################################################################
# Prompt Settings
###########################################################################

function ps-color() {
  local codes=''
  for arg in "$@"; do
    case "$arg" in
      reset)      codes="$codes;0";;
      black)      codes="$codes;30";;
      red)        codes="$codes;31";;
      green)      codes="$codes;32";;
      yellow)     codes="$codes;33";;
      blue)       codes="$codes;34";;
      magenta)    codes="$codes;35";;
      cyan)       codes="$codes;36";;
      white)      codes="$codes;37";;
      on-black)   codes="$codes;40";;
      on-red)     codes="$codes;41";;
      on-green)   codes="$codes;42";;
      on-yellow)  codes="$codes;43";;
      on-blue)    codes="$codes;44";;
      on-magenta) codes="$codes;45";;
      on-cyan)    codes="$codes;46";;
      on-white)   codes="$codes;47";;
      bold)       codes="$codes;1";;
    esac
  done
  echo "\[\033[${codes}m\]"
}

function prompt_preexec()
{
  _command_start_time=$(date +%s)
}
prompt_preexec

# Catch an enter keypress and call our preexec function.
bind -x '"\M-\C-h1": prompt_preexec'
bind '"\M-\C-h2": accept-line'
bind '"\C-j": "\M-\C-h1\M-\C-h2"'
bind '"\C-m": "\M-\C-h1\M-\C-h2"'

_last_exit_status=0

function prompt_ps1_elapsed_time()
{
  local time="$1"
  local elapsed=$(($time - $_command_start_time))
  if [ $elapsed -gt 3600 ]; then
    local hours=$(($elapsed / 3600))
    local minutes=$((($elapsed % 3600) / 60))
    local seconds=$(($elapsed % 60))
    echo "${hours}h${minutes}m${seconds}s "
  elif [ $elapsed -gt 60 ]; then
    local minutes=$(($elapsed / 60))
    local seconds=$(($elapsed % 60))
    echo "${minutes}m${seconds}s "
  elif [ $elapsed -gt 1 ]; then
    echo "${elapsed}s "
  fi
}

function prompt_ps1_exit_status_1()
{
  if [ $_last_exit_status -ne 0 ]; then
    echo $_last_exit_status
  fi
}

function prompt_ps1_exit_status_2()
{
  if [ $_last_exit_status -ne 0 ]; then
    echo " "
  fi
}

function prompt_ps1_job_count()
{
  local job_count="$1"
  if [ "$job_count" -ne 0 ]; then
    echo " ($job_count)"
  fi
}

function prompt_ps1_shlvl()
{
  if [ "$SHLVL" -ne 1 ]; then
    echo " *$SHLVL"
  fi
}

function prompt_ps1_git_branch()
{
  local git_branch_out
  local git_branch_out_line
  if [ -e .git ]; then
    git_branch_out=$(command git branch -vv 2>/dev/null)
    if [[ "$git_branch_out" == "" ]]; then
      return
    fi
    local re="^\\* (\\(([^)]*)\\)|([^ ]*))"
    while read -r git_branch_out_line; do
      if [[ "$git_branch_out_line" =~ $re ]]; then
        local current_branch="${BASH_REMATCH[2]:-${BASH_REMATCH[3]}}"
        local re2="((ahead|behind)[^]]*)\\]"
        if [[ "$git_branch_out_line" =~ $re2 ]]; then
          current_branch="$current_branch: ${BASH_REMATCH[1]}"
        fi
        echo "${current_branch}${ahead_behind} "
        break
      fi
    done <<< "$git_branch_out"
  fi
}

function prompt_ps1_svn_branch()
{
  if [ -e .svn ]; then
    url_out=$(command svn info 2>/dev/null | grep '^URL:')
    re_branch="\\<(tags|branches)/([^/]*)\\>"
    re_trunk="\\<trunk\\>"
    if [[ "$url_out" =~ $re_branch ]]; then
      echo "${BASH_REMATCH[2]} "
    elif [[ "$url_out" =~ $re_trunk ]]; then
      echo "${BASH_REMATCH[0]} "
    fi
  fi
}

# elapsed time
PS1="$(ps-color bold blue)\$(prompt_ps1_elapsed_time \D{%s})"
# exit status
PS1="${PS1}$(ps-color bold white on-red)\$(prompt_ps1_exit_status_1)$(ps-color reset)\$(prompt_ps1_exit_status_2)"
# user name and host name
if [ "$USER" = "root" ]; then
  PS1="${PS1}$(ps-color bold red)"
else
  PS1="${PS1}$(ps-color bold magenta)"
fi
PS1="${PS1}\u@\H"
# working directory
PS1="${PS1} $(ps-color bold cyan)\w"
# job count
PS1="${PS1}$(ps-color bold blue)\$(prompt_ps1_job_count \\j)"
# shell level
PS1="${PS1}$(ps-color bold green)\$(prompt_ps1_shlvl)"
# \n
PS1="${PS1}$(ps-color reset)\n"
# git/svn info
PS1="${PS1}$(ps-color bold yellow)\$(prompt_ps1_git_branch)\$(prompt_ps1_svn_branch)"
# dollar
PS1="${PS1}$(ps-color reset)\$ "

PROMPT_COMMAND="_last_exit_status=\$?"

case "$TERM" in
[ax]term*|rxvt*)
  function prompt_command_change_terminal_title()
  {
    local dirname=""
    if [[ "${PWD}" == "${HOME}" ]]; then
      dirname="~"
    elif [[ "${PWD}" =~ .*/(.*) ]]; then
      dirname="${BASH_REMATCH[1]}"
    fi
    echo -ne "\033]0;"$dirname" [${USER}@${HOSTNAME}: ${PWD}]\007"
  }
  PROMPT_COMMAND="$PROMPT_COMMAND;prompt_command_change_terminal_title"
  ;;
*)
  :
  ;;
esac

# I intend ps-color to only be used at initialization time so as to not slow
# prompt string generation at runtime. This is my double-check.
unset -f ps-color

###########################################################################
# cd hooks
###########################################################################

function cd() { builtin cd "$@"; cd_hook; }
function pushd() { builtin pushd "$@"; cd_hook; }
function popd() { builtin popd "$@"; cd_hook; }

function cd_hook_cat_todo()
{
  if [[ -r .todo ]]; then
    echo TODO:
    sed -re 's/^/  /' .todo
  fi
}
function cd_hook_show_git_status()
{
  if [[ -e .git ]]; then
    git status
  fi
}
function cd_hook_show_svn_status()
{
    if [[ -e .svn ]]; then
        jsvn status
    fi
}
function cd_hook()
{
  if [[ $BASH_SUBSHELL == 0 ]]; then
    # do not invoke these CD hooks in subshells
    if [[ "${cd_hook_last_wd}" != "${PWD}" ]]; then
      cd_hook_cat_todo
      cd_hook_show_git_status
      cd_hook_show_svn_status
      cd_hook_last_wd="${PWD}"
    fi
  fi
}
# Invoke cd_hook when we're loaded
cd_hook

###########################################################################
# command aliases/wrappers
###########################################################################

alias grep='grep --color=auto'
alias grepnosvn='grep --color=auto --exclude-dir=".svn" --exclude-dir=".git"'
alias egrepnosvn='egrep --color=auto --exclude-dir=".svn" --exclude-dir=".git"'
#function gvim()
#{
#  arg="$1"
#  if [ "${arg}" = "" ]; then
#    command gvim
#  else
#    command gvim --remote-tab-silent "$@"
#  fi
#}
alias cribbage='cribbage -r'
alias backgammon='backgammon -r -pb'
alias ls='ls --color=auto'
alias strip-cr="sed -e 's/\x0d//'"
alias rip='abcde -x -p -o mp3:"-v -b160"'
function rip-dvd()
{
  name="$1"
  if [ "$name" == "" ]; then
    echo 'specify dvd name'
  else
    mplayer dvd://1 -v -dupstream -dumpfile "$name.vob"
    mencoder -ovc xvid -oac mp3lame -xvidencopts fixed_quant=4 -lameopts cbr:br=192:aq=1 -aid 128 -sid 0 -o "$name.avi" "$name.vob"
  fi
}
# Catch and compare output
function cco()
{
  local catch_compare_output_new=$("$@" 2>&1)
  if [[ "$catch_compare_output" == "" ]]; then
    echo "$catch_compare_output_new"
  elif [[ "$catch_compare_output" == "$catch_compare_output_new" ]]; then
    echo "$catch_compare_output_new"
  else
    colordiff -u9999 <(echo "$catch_compare_output") <(echo "$catch_compare_output_new") | tail -n+4
  fi
  catch_compare_output="$catch_compare_output_new"
}

if [[ "$(which jsvn 2>/dev/null)" != "" ]]; then
  alias svn='jsvn'
fi
alias jindent='indent -bbo -bl -blf -bli0 -bls -i4 -npcs -nut -ts8'
alias rsync-vfat='rsync -rtv --stats --modify-window=2'

###########################################################################
# environment configuration
###########################################################################

export LESS='Ri'
export EDITOR=vim
export LC_COLLATE=C

###########################################################################
# bash configuration
###########################################################################

HISTCONTROL='ignoreboth'
HISTSIZE=5000
HISTFILESIZE=${HISTSIZE}

# source any machine-local aliases
# this way ~/.bash_aliases can be shared in many places
if [ -f ~/.bash_aliases.local ]; then
  . ~/.bash_aliases.local
fi

# source any alias files in ~/.bash_aliases.d,
# or within a subdirectory thereof
# this allows multiple alias files or repositories of alias files
for f in ~/.bash_aliases.d/* ~/.bash_aliases.d/*/*; do
  if [ -f $f ]; then
    . $f
  fi
done

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

#function prompt_preexec()
#{
#  false
#}

# Catch an enter keypress and call our preexec function.
#bind -x '"\M-\C-h1": prompt_preexec'
#bind '"\M-\C-h2": accept-line'
#bind '"\C-j": "\M-\C-h1\M-\C-h2"'
#bind '"\C-m": "\M-\C-h1\M-\C-h2"'

_last_exit_status=0

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
        echo " ${current_branch}${ahead_behind}"
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
      echo " ${BASH_REMATCH[2]}"
    elif [[ "$url_out" =~ $re_trunk ]]; then
      echo " ${BASH_REMATCH[0]}"
    fi
  fi
}

if [[ "${USER}" == "root" ]]; then
  PS1="$(ps-color bold white on-red)\$(prompt_ps1_exit_status_1)$(ps-color reset)\$(prompt_ps1_exit_status_2)$(ps-color bold red)\u@\H$(ps-color bold green) \w$(ps-color bold magenta) \d \t$(ps-color bold blue)\$(prompt_ps1_job_count \\j)$(ps-color bold cyan)\$(prompt_ps1_shlvl)$(ps-color reset)\n\$ "
else
  PS1="$(ps-color bold white on-red)\$(prompt_ps1_exit_status_1)$(ps-color reset)\$(prompt_ps1_exit_status_2)$(ps-color bold green)\u@\H$(ps-color bold cyan) \w$(ps-color bold magenta) \d \t$(ps-color bold blue)\$(prompt_ps1_job_count \\j)$(ps-color bold cyan)\$(prompt_ps1_shlvl)$(ps-color bold yellow)\$(prompt_ps1_git_branch)\$(prompt_ps1_svn_branch)$(ps-color reset)\n\$ "
fi

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
function git-config-joshs()
{
  git config --global user.name 'Josh Holtrop'
  git config --global color.ui true
  git config --global color.diff.meta yellow
  git config --global core.excludesfile ${HOME}/.gitignore
  git config --global core.pager 'less -FRXi'
  git config --global alias.dc 'diff --cached'
  # from http://stackoverflow.com/questions/1057564/pretty-git-branch-graphs/9074343#9074343
  git config --global alias.lg 'log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) - %C(magenta)%an%C(reset)%C(bold yellow)%d%C(reset)%n          %C(white)%s%C(reset)" --all'
  git config --global alias.lg1 'log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) - %C(magenta)%an%C(reset)%C(bold yellow)%d%C(reset)%n          %C(white)%s%C(reset)"'
  git config --global alias.mergef 'merge FETCH_HEAD'
  git config --global alias.gdiff 'difftool -y -t gvimdiff'
  git config --global alias.gdiffc 'difftool -y -t gvimdiff --cached'
  git config --global alias.wdiff 'diff --word-diff=color'
  git config --global alias.mktar '!function f { name="$1"; pos="$2"; if [ "$pos" == "" ]; then pos=HEAD; fi; git archive --prefix="$name"/ "$pos" | bzip2 > ../"$name".tar.bz2; }; f'
  git config --global alias.mktarxz '!function f { name="$1"; pos="$2"; if [ "$pos" == "" ]; then pos=HEAD; fi; git archive --prefix="$name"/ "$pos" | xz > ../"$name".tar.xz; }; f'
  git config --global alias.amd 'am --committer-date-is-author-date'
  git config --global push.default upstream
  git config --global alias.bcdiff 'difftool -y -t bc3'
  git config --global alias.bcdiffc 'difftool -y -t bc3 --cached'
  git config --global difftool.bc3.cmd 'git_bc3diff "$LOCAL" "$REMOTE"'
  git config --global alias.bcmerge 'mergetool -y -t bc3'
  git config --global mergetool.bc3.cmd \
    'git_bc3merge "$LOCAL" "$REMOTE" "$MERGED"'
  git config --global mergetool.bc3.trustExitCode false
}
function git-config-local-personal()
{
  local domain='gmail.com'
  git config user.email 'jholtrop@'${domain}
}
alias git-find-lost-commit='git fsck --lost-found'
git_empty_commit='4b825dc642cb6eb9a060e54bf8d69288fbee4904'

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

###########################################################################
# mark
###########################################################################

function mark()
{
  local MARKS_FILE=${HOME}/.marks
  local param="$1"
  local mark_name=""
  local mark_value=""
  if [[ ! -f ${MARKS_FILE} ]]; then
    touch ${MARKS_FILE}
  fi
  case "$param" in
  -g|-s|-d)
    mark_name="$2"
    mark_value=$(grep -i "^$mark_name:" ${MARKS_FILE} | sed -e 's/[^:]*://')
    if [[ "$mark_value" == "" ]]; then
      echo "\`$mark_name' is NOT in mark list!"
      return
    fi
    ;;
  esac
  case "$param" in
  -g)
    cd "$mark_value"
    ;;
  -s)
    echo "$mark_value"
    ;;
  -h|--help)
    echo "mark <name> [<dir>]: mark <dir> (default \$PWD) as <name>"
    echo "mark -g <name>     : goto mark <name>"
    echo "mark -s <name>     : show mark <name>"
    echo "mark -d <name>     : delete mark <name>"
    echo "mark -l            : list all marks"
    ;;
  -l)
    cat ${MARKS_FILE}
    ;;
  -d)
    grep -v "^$mark_name:" ${MARKS_FILE} > ${MARKS_FILE}.tmp
    mv ${MARKS_FILE}.tmp ${MARKS_FILE}
    ;;
  -*)
    echo "Unrecognized option"
    ;;
  *)
    local mark_name="$1"
    local mark_value="$2"
    if [[ "$mark_value" == "" ]]; then
      mark_value=`pwd`
    fi
    grep -v "^$mark_name:" ${MARKS_FILE} > ${MARKS_FILE}.tmp
    mv ${MARKS_FILE}.tmp ${MARKS_FILE}
    echo "$mark_name:$mark_value" >> ${MARKS_FILE}
    ;;
  esac
}

###########################################################################
# cygwin-specific
###########################################################################
if [[ -e /bin/cygwin1.dll ]]; then
  alias ip="ipconfig | grep -E 'IP(v4)? Address' | sed -e 's/.*: //'"

  function cs
  {
    while [[ "$1" != "" ]]
    do
      if [[ -e "$1" ]]; then
        dn=$(dirname "$1")
        bn=$(basename "$1")
        (cd "$dn"; HOME='' cygstart "$bn")
      else
        HOME='' cygstart "$1"
      fi
      shift
    done
  }

  function winpython
  {
    local winpython=/c/Python27/python.exe
    if [[ "$1" == "" ]]; then
      ${winpython} -i
    else
      ${winpython} "$@"
    fi
  }

  winpath="$(echo $PATH | sed -e 's/:/\n/g' | grep cygdrive | tr '\n' ':' | sed -e 's/:*$//')"

  export SSH_AUTH_SOCK=/tmp/.ssh_socket

  function ssh_agent_start
  {
    # cygwin ssh-agent support, from
    # http://www.webweavertech.com/ovidiu/weblog/archives/000326.html

    ssh-add -l >/dev/null 2>&1

    if [ $? = 2 ]; then
      # exit status 2 means we couldn't connect to ssh-agent,
      # so let's start one now
      rm -f $SSH_AUTH_SOCK
      ssh-agent -a $SSH_AUTH_SOCK >/tmp/.ssh-script
      . /tmp/.ssh-script
      echo $SSH_AGENT_PID >/tmp/.ssh-agent-pid
      ssh-add ~/.ssh/JoshHoltropGentex
    fi
  }

  function ssh_agent_stop
  {
    pid=$(cat /tmp/.ssh-agent-pid)
    kill $pid
  }
fi

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

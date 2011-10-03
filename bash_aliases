# vim:syntax=sh
if [[ "`whoami`" == "root" ]]; then
    PS1='\[\033[31;1m\]\u@\H\[\033[32;1m\] [\w]\[\033[35;1m\] \d \t \[\033[34;1m\](\j)\n\$ \[\033[0m\]'
else
    PS1='\[\033[32;1m\]\u@\H\[\033[31;1m\] [\w]\[\033[35;1m\] \d \t \[\033[34;1m\](\j)\n\$ \[\033[0m\]'
fi
# alternate PS1:
# PS1='[\[\033[31;1m\]\u@\H\[\033[34;1m\] \w\[\033[0m\]]\$ \[\033[0m\]'
case "$TERM" in
[ax]term*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    ;;
*)
    ;;
esac
alias grep='grep --color=auto'
alias grepnosvn='grep --color=auto --exclude-dir=".svn"'
alias egrepnosvn='egrep --color=auto --exclude-dir=".svn"'
alias gvim='gvim --remote-tab-silent'
alias cribbage='cribbage -r'
alias backgammon='backgammon -r -pb'
# put 'cattodo' in $PROMPT_COMMAND to use
alias cattodo='if [[ $CATTODO_LAST_WD != $PWD ]]; then if [[ -r .todo ]]; then cat .todo; fi; CATTODO_LAST_WD=$PWD; fi'
alias ls='ls --color=auto'
alias strip-cr="sed -e 's/\x0d//'"
alias rip='abcde -x -p -o mp3:"-v -b160"'
export LESS='Ri'
HISTCONTROL='ignoreboth'
HISTSIZE=5000
HISTFILESIZE=${HISTSIZE}
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
export EDITOR=vim
function git-config-joshs()
{
    git config --global user.name 'Josh Holtrop'
    local domain='gmail.com'
    git config --global user.email 'jholtrop+git@'${domain}
    git config --global color.ui true
    git config --global core.excludesfile ${HOME}/.gitignore
    git config --global core.pager 'less -FRXi'
    git config --global alias.dc 'diff --cached'
    git config --global alias.mergef 'merge FETCH_HEAD'
    git config --global alias.gdiff 'difftool -y -t gvimdiff'
    git config --global alias.gdiffc 'difftool -y -t gvimdiff --cached'
    git config --global alias.wdiff 'diff --word-diff=color'
    if [ -e /bin/cygwin1.dll ]; then
        git config --global alias.bcdiff 'difftool -y -t bc2'
        git config --global alias.bcdiffc 'difftool -y -t bc2 --cached'
        git config --global difftool.bc2.cmd 'git_bc2diff "$LOCAL" "$REMOTE"'
        git config --global alias.bcmerge 'mergetool -y -t bc2'
        git config --global mergetool.bc2.cmd \
            'git_bc2merge "$LOCAL" "$REMOTE" "$MERGED"'
        git config --global mergetool.bc2.trustExitCode false
    fi
}
alias git-find-lost-commit='git fsck --lost-found'
if [[ "$(which jsvn 2>/dev/null)" != "" ]]; then
    alias svn='jsvn'
fi
alias jindent='indent -bbo -bl -blf -bli0 -bls -i4 -npcs -nut -ts8'

# cygwin-specific aliases
if [ -e /bin/cygwin1.dll ]; then
    alias ip="ipconfig | grep -E 'IP(v4)? Address' | sed -e 's/.*: //'"
fi

# source any machine-local aliases
# this way ~/.bash_aliases can be a symlink to a version-controlled
# aliases file
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

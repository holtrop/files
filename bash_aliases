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
alias svnst='svn st | grep -v "^X" | grep -v "^\$"'
alias svn-root="svn info | grep '^URL: ' | sed -e 's/^URL: //' -re 's/\/(trunk|tags|branches)\>.*//'"
function svn-branch()
{
    # do from anywhere in a working copy of the repository
    # usage: svn-branch branch-name -m "comment"
    branch_name="$1"
    shift 1
    svn copy `svn-root`/trunk `svn-root`/branches/"$branch_name" "$@"
}
function svn-merge-branch()
{
    # usage: svn-merge-branch branch-name branch-dir -m "comment"
    branch_name="$1"
    branch_dir="$2"
    shift 2
    branch_rev=$(svn log --stop-on-copy `svn-root`/branches/"$branch_name" | egrep -A1 -- '-{50}' | egrep '^r[0-9]+' | tail -n 1 | sed -re 's/^r([0-9]+).*/\1/')
    svn merge -r${branch_rev}:HEAD `svn-root`/branches/"$branch_name""$branch_dir" "$@"
}
alias cribbage='cribbage -r'
alias backgammon='backgammon -r -pb'
# put 'cattodo' in $PROMPT_COMMAND to use
alias cattodo='if [[ $LAST_WD != $PWD ]]; then if [[ -r .todo ]]; then cat .todo; fi; LAST_WD=$PWD; fi'
alias ls='ls --color=auto'
export LESS='Ri'
function mark()
{
    MARKS_FILE=${HOME}/.marks
    param="$1"
    if [[ ! -f ${MARKS_FILE} ]]; then
        touch ${MARKS_FILE}
    fi
    case "$param" in
    -g)
        mark_name="$2"
        mark_dir=$(grep "^$mark_name:" ${MARKS_FILE} | sed -e 's/[^:]*://')
        if [[ "$mark_dir" != "" ]]; then
            cd "$mark_dir"
        fi
        ;;
    -s)
        mark_name="$2"
        mark_dir=$(grep "^$mark_name:" ${MARKS_FILE} | sed -e 's/[^:]*://')
        echo "$mark_dir"
        ;;
    -h)
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
        mark_name="$2"
        grep -v "^$mark_name:" ${MARKS_FILE} > ${MARKS_FILE}.tmp
        mv ${MARKS_FILE}.tmp ${MARKS_FILE}
        ;;
    -*)
        echo "Unrecognized option"
        ;;
    *)
        mark_name="$1"
        mark_dir="$2"
        if [[ "$mark_dir" == "" ]]; then
            mark_dir=`pwd`
        fi
        grep -v "^$mark_name:" ${MARKS_FILE} > ${MARKS_FILE}.tmp
        mv ${MARKS_FILE}.tmp ${MARKS_FILE}
        echo "$mark_name:$mark_dir" >> ${MARKS_FILE}
        ;;
    esac
}
alias gitdc='git diff --cached'
export EDITOR=vim
function git-config-joshs()
{
    git config --global user.name 'Josh Holtrop'
    domain='gmail.com'
    git config --global user.email 'jholtrop+git@'${domain}
    git config --global push.default matching
    git config --global color.ui true
    git config --global core.excludesfile ${HOME}/.gitignore
    git config --global core.pager 'less -FRXi'
}
function svn()
{
    subcommand="$1"
    realsvn=$(which svn 2>/dev/null)
    colorsvn=$(which colorsvn 2>/dev/null)
    colordiff=$(which colordiff 2>/dev/null)
    if [[ "$realsvn" == "" ]]; then
        echo "Subversion not found in \$PATH"
        return
    fi
    if [[ "$subcommand" == "diff" && "$colordiff" != "" ]]; then
        ${realsvn} "$@" | ${colordiff}
        return
    fi
    if [[ "$colorsvn" != "" ]]; then
        ${colorsvn} "$@"
        return
    fi
    ${realsvn} "$@"
}

# local

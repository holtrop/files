# vim:syntax=sh
PS1='\[\033[32;1m\]\u@\H\[\033[31;1m\] [\w]\[\033[35;1m\] \d \t \[\033[34;1m\](\j)\n\$ \[\033[0m\]'
# alternate PS1:
# PS1='[\[\033[31;1m\]\u@\H\[\033[34;1m\] \w\[\033[0m\]]\$ \[\033[0m\]'
case "$TERM" in
[ax]term*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    ;;
*)
    ;;
esac
export LESS='-i'
alias grepnosvn='grep --exclude-dir=".svn"'
alias egrepnosvn='egrep --exclude-dir=".svn"'
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
    # assumes you are in the working copy "trunk" directory
    # usage: svn-merge-branch branch-name -m "comment"
    branch_name="$1"
    shift 1
    branch_rev=$(svn log --stop-on-copy `svn-root`/branches/"$branch_name" | egrep -A1 -- '-{50}' | egrep '^r[0-9]+' | tail -n 1 | sed -re 's/^r([0-9]+).*/\1/')
    svn merge -r${branch_rev}:HEAD `svn-root`/branches/"$branch_name" "$@"
}
# put 'cattodo' in $PROMPT_COMMAND to use
alias cattodo='if [[ $LAST_WD != $PWD ]]; then if [[ -r .todo ]]; then cat .todo; fi; LAST_WD=$PWD; fi'

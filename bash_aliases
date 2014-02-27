# vim:syntax=sh
if [[ "`whoami`" == "root" ]]; then
    PS1='\[\033[31;1m\]\u@\H\[\033[32;1m\] [\w]\[\033[35;1m\] \d \t \[\033[34;1m\](\j)\n\$ \[\033[0m\]'
else
    PS1='\[\033[32;1m\]\u@\H\[\033[31;1m\] [\w]\[\033[35;1m\] \d \t \[\033[34;1m\](\j)\[\033[33;1m\]$(prompt_ps1_git_branch)$(prompt_ps1_svn_branch)\[\033[34;1m\]\n\$ \[\033[0m\]'
fi
# alternate PS1:
# PS1='[\[\033[31;1m\]\u@\H\[\033[34;1m\] \w\[\033[0m\]]\$ \[\033[0m\]'
case "$TERM" in
[ax]term*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;"$(basename "$PWD")" [${USER}@${HOSTNAME}: ${PWD}]\007"'
    ;;
*)
    PROMPT_COMMAND=''
    ;;
esac
alias grep='grep --color=auto'
alias grepnosvn='grep --color=auto --exclude-dir=".svn"'
alias egrepnosvn='egrep --color=auto --exclude-dir=".svn"'
function gvim()
{
    arg="$1"
    if [ "${arg}" = "" ]; then
        command gvim
    else
        command gvim --remote-tab-silent "$@"
    fi
}
alias cribbage='cribbage -r'
alias backgammon='backgammon -r -pb'
# put 'cattodo' in $PROMPT_COMMAND to use
alias cattodo='if [[ $CATTODO_LAST_WD != $PWD ]]; then if [[ -r .todo ]]; then echo TODO:; cat .todo; fi; CATTODO_LAST_WD=$PWD; fi'
alias cdshowgitstatus='if [[ $CDSHOWGITSTATUS_LAST_WD != $PWD ]]; then if [[ -e .git ]]; then git status; fi; CDSHOWGITSTATUS_LAST_WD=$PWD; fi'
PROMPT_COMMAND="cdshowgitstatus;$PROMPT_COMMAND"
function prompt_ps1_git_branch()
{
    if [ -e .git ]; then
        branch_out=$(command git branch -vv 2>/dev/null | grep '^\*')
        if [[ "$branch_out" == "" ]]; then
            return
        fi
        re="^\\* (.no.branch.|\\(detached[^)]*\\)|[^ ]*)"
        if [[ "$branch_out" =~ $re ]]; then
            current_branch="${BASH_REMATCH[1]}"
            re="((ahead|behind)[^]]*)\\]"
            if [[ "$branch_out" =~ $re ]]; then
                current_branch="$current_branch: ${BASH_REMATCH[1]}"
            fi
            echo " [${current_branch}${ahead_behind}]"
        fi
    fi
}
#put $(prompt_ps1_git_branch) in $PS1 to use it
function prompt_ps1_svn_branch()
{
    if [ -e .svn ]; then
        url_out=$(command svn info 2>/dev/null | grep '^URL:')
        re_branch="\\<(tags|branches)/([^/]*)\\>"
        re_trunk="\\<trunk\\>"
        if [[ "$url_out" =~ $re_branch ]]; then
            echo " [${BASH_REMATCH[2]}]"
        elif [[ "$url_out" =~ $re_trunk ]]; then
            echo " [${BASH_REMATCH[0]}]"
        fi
    fi
}
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
    git config --global color.ui true
    git config --global color.diff.meta yellow
    git config --global core.excludesfile ${HOME}/.gitignore
    git config --global core.pager 'less -FRXi'
    git config --global alias.dc 'diff --cached'
    # from http://stackoverflow.com/questions/1057564/pretty-git-branch-graphs/9074343#9074343
    git config --global alias.lg 'log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) - %C(magenta)%an%C(reset)%C(bold yellow)%d%C(reset)%n          %C(white)%s%C(reset)" --all'
    git config --global alias.mergef 'merge FETCH_HEAD'
    git config --global alias.gdiff 'difftool -y -t gvimdiff'
    git config --global alias.gdiffc 'difftool -y -t gvimdiff --cached'
    git config --global alias.wdiff 'diff --word-diff=color'
    git config --global alias.mktar '!function f { name="$1"; pos="$2"; if [ "$pos" == "" ]; then pos=HEAD; fi; git archive --prefix="$name"/ "$pos" | bzip2 > ../"$name".tar.bz2; }; f'
    git config --global alias.mktarxz '!function f { name="$1"; pos="$2"; if [ "$pos" == "" ]; then pos=HEAD; fi; git archive --prefix="$name"/ "$pos" | xz > ../"$name".tar.xz; }; f'
    git config --global push.default upstream
    if [ -e /bin/cygwin1.dll ]; then
        git config --global alias.bcdiff 'difftool -y -t bc3'
        git config --global alias.bcdiffc 'difftool -y -t bc3 --cached'
        git config --global difftool.bc3.cmd 'git_bc3diff "$LOCAL" "$REMOTE"'
        git config --global alias.bcmerge 'mergetool -y -t bc3'
        git config --global mergetool.bc3.cmd \
            'git_bc3merge "$LOCAL" "$REMOTE" "$MERGED"'
        git config --global mergetool.bc3.trustExitCode false
    fi
}
function git-config-local-personal()
{
    local domain='gmail.com'
    git config user.email 'jholtrop@'${domain}
}
alias git-find-lost-commit='git fsck --lost-found'
if [[ "$(which jsvn 2>/dev/null)" != "" ]]; then
    alias svn='jsvn'
fi
alias jindent='indent -bbo -bl -blf -bli0 -bls -i4 -npcs -nut -ts8'

# cygwin-specific aliases
if [ -e /bin/cygwin1.dll ]; then
    alias ip="ipconfig | grep -E 'IP(v4)? Address' | sed -e 's/.*: //'"
    function cs
    {
        while [ "$1" != "" ]
        do
            dn=$(dirname "$1")
            bn=$(basename "$1")
            (cd "$dn"; HOME='' cygstart "$bn")
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
    alias winpath="PATH=\"$(echo $PATH | sed -e 's/:/\n/g' | grep cygdrive | tr '\n' ':')\""
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

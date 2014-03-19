# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Aliases
if [ -f "${HOME}/.bash_aliases" ]; then
    source "${HOME}/.bash_aliases"
fi

if [ -e /bin/cygwin1.dll ]; then
    function ssh
    {
        ssh_agent_start
        command ssh "$@"
    }

    # for scons
    unset ALLUSERSPROFILE

    if [[ "$(ps -ef | grep XWin | grep -v grep)" == "" ]]; then
        cygstart --hide startxwin
    fi
fi

if [ -f "${HOME}/.bashrc.local" ]; then
    source "${HOME}/.bashrc.local"
fi

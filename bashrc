# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Aliases
if [ -f "${HOME}/.bash_aliases" ]; then
    source "${HOME}/.bash_aliases"
fi

if [ -e /bin/cygwin1.dll ]; then
    # cygwin ssh-agent support, from
    # http://www.webweavertech.com/ovidiu/weblog/archives/000326.html

    export SSH_AUTH_SOCK=/tmp/.ssh_socket

    ssh-add -l >/dev/null 2>&1

    if [ $? = 2 ]; then
        # exit status 2 means we couldn't connect to ssh-agent,
        # so let's start one now
        rm -f $SSH_AUTH_SOCK
        ssh-agent -a $SSH_AUTH_SOCK >/tmp/.ssh-script
        . /tmp/.ssh-script
        echo $SSH_AGENT_PID >/tmp/.ssh-agent-pid
        ssh-add ~/.ssh/josh-walter
    fi

    function kill-agent
    {
        pid=$(cat /tmp/.ssh-agent-pid)
        kill $pid
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

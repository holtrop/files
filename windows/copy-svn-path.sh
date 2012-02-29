#!/bin/bash
# This script can be added to the Windows right-click context menu for all
# files to provide a "Copy SVN URL" function
export PATH=/cygdrive/c/cygwin/bin:$PATH
fname="$1"
uname=$(cygpath -u "$fname")
pth=$(svn info "$uname" 2>/dev/null | grep '^URL:' | sed -re 's/^URL:.//')
echo -n "$pth" | clip

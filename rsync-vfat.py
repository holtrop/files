#!/usr/bin/env python

import sys
import os
from subprocess import Popen, PIPE
import getopt

def main(argv):
    dry_run = False
    opts, args = getopt.getopt(argv[1:], 'n')
    for opt, val in opts:
        if opt == '-n':
            dry_run = True
    if len(args) != 2:
        sys.stderr.write('Usage: %s [-n] source destination\n' % argv[0])
        return -2
    out = Popen(['grep', '-v', '/$'], stdin=PIPE).stdin
    cmd = ['rsync', '-av%s' % ('n' if dry_run else ''), '--delete',
           '--modify-window=2'] + args
    sys.stdout.write(' '.join(cmd) + '\n')
    Popen(cmd, stdout=out).wait()

if __name__ == '__main__':
    sys.exit(main(sys.argv))

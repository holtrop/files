#!/usr/bin/env python

import os
import sys
import getopt
from subprocess import *

def main(argv):
    bitrate = 128
    try:
        opts, args = getopt.getopt(argv[1:], "b:")
    except getopt.GetoptError:
        usage()
        return 2

    for opt, arg in opts:
        if opt == "-b":
            bitrate = arg
        else:
            usage()
            return 2

    for f in args:
        if os.path.isfile(f):
            Popen(['lame', '-v', '-b', str(bitrate), f, f + '.mp3']).wait()

if __name__ == "__main__":
    main(sys.argv)

#!/usr/bin/env python

import os
import sys
from subprocess import *

def main(argv):
    for f in argv:
        if os.path.isfile(f):
            Popen(['lame', '-v', f, f + '.mp3']).wait()

if __name__ == "__main__":
    main(sys.argv)

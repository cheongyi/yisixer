#!/usr/bin/python

import os, sys


if len(sys.argv) < 2:
    print "Usage: %s 1|2|3|4|x" % sys.argv[0]
    sys.exit(1)

v = sys.version_info
print('Your current python is %d.%d Please use Python 3.6.' % (v.major, v.minor))

if __name__ == '__main__':
    operation = sys.argv[1]
    path = sys.path[0]
    print path

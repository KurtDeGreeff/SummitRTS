#!/usr/bin/python

import random
import sys

def flip():
    return random.randint(0,9999)

def convertFlip(input):
    if input % 2:
        return True
    return False

def getData():
    evens = 0
    odds  = 0
    for i in range(101):
        if convertFlip(flip()):
            evens += 1
        else:
            odds  += 1
    if evens > odds:
        return "EVEN"
    return "ODD"

def main():
    val = getData()

    with open(sys.argv[1], 'wb') as f:
        f.writelines('%s\n' % val)

    sys.exit(0)

if __name__ == "__main__":
    main()

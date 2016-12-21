#!/usr/bin/python

import random
import sys
from Tkinter import *


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

def winDisplay(output):
    root = Tk()
    root.wm_title("Coin Flipped")
    T = Text(root, height=3, width=30)
    T.tag_configure('boldify', justify="center", font=('Arial', 16, 'bold'))
    T.pack()
    T.insert(END, output, 'boldify')
    mainloop()

def main():
    val = getData()

    with open(sys.argv[1], 'wb') as f:
        f.write(val)

    winDisplay(val)
    sys.exit(0)

if __name__ == "__main__":
    main()

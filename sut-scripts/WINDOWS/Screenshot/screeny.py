import argparse
import os
import sys
import wx

# requires wxPython from http://wxpython.org/download.php

def getArgs():
    """
    Gets the arguments for processing
    
    return object args
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output', required="true")
    parser.add_argument('-d', '--directory', required="true")
    args = parser.parse_args()
    return args

def doScreenGrab(args):
    """
    Take the picture of the currently active screen
    saves in location specified
    
    param args: object arguments
    """
    app = wx.App()  # Need to create an App instance before doing anything

    screen = wx.ScreenDC()
    size = screen.GetSize()
    bmp = wx.EmptyBitmap(size[0], size[1])
    mem = wx.MemoryDC(bmp)
    mem.Blit(0, 0, size[0], size[1], screen, 0, 0)

    del mem  # Release bitmap
    saveLocation = '%s.png' % (os.path.join(args.directory, args.output))
    bmp.SaveFile('%s' % saveLocation, wx.BITMAP_TYPE_PNG)

def main():
    """
    Main function to do all of the calls to the sub functions
    """
    args = getArgs()
    doScreenGrab(args)
    sys.exit(0)
    
if __name__ == "__main__":
    main()
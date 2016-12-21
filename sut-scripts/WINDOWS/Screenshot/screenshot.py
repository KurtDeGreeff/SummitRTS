import argparse
import os
import sys
import time
import win32gui, win32ui, win32con, win32api

# Get arguments for processing
parser = argparse.ArgumentParser()
parser.add_argument('-o', '--output', required="true")
parser.add_argument('-m', '--minimize', default=False, action='store_true')
parser.add_argument('-d', '--directory', required="true")
args = parser.parse_args()

def minimize_all_windows():
    """
    Using the windows internal command interpreter to minimize all windows
    prior to taking the screenshot, this 
    """
    import win32com.client
    vbhost = win32com.client.Dispatch("ScriptControl")
    vbhost.language = "vbscript"
    vbhost.addcode(
        """
        Dim oShell
        Set oShell = CreateObject("Shell.Application")
        oShell.MinimizeAll
        """ )
    del vbhost
    return

def take_screenshot():
    # get the active desktop window
    hwin = win32gui.GetDesktopWindow()
    # work with the screen dimensions
    width = win32api.GetSystemMetrics(win32con.SM_CXVIRTUALSCREEN)
    height = win32api.GetSystemMetrics(win32con.SM_CYVIRTUALSCREEN)
    left = win32api.GetSystemMetrics(win32con.SM_XVIRTUALSCREEN)
    top = win32api.GetSystemMetrics(win32con.SM_YVIRTUALSCREEN)

    hwindc = win32gui.GetWindowDC(hwin)
    srcdc = win32ui.CreateDCFromHandle(hwindc)
    memdc = srcdc.CreateCompatibleDC()

    # setup the container for the png output with the proper dimensions
    png = win32ui.CreateBitmap()
    png.CreateCompatibleBitmap(srcdc, width, height)

    # push the screen data into the container
    memdc.SelectObject(png)
    memdc.BitBlt((0, 0), (width, height), srcdc, (left, top), win32con.SRCCOPY)

    # save and close the png file
    outputFileLocation  = '%s.png' % os.path.join(args.directory, args.output)
    png.SaveBitmapFile(memdc, outputFileLocation)

def main():
    # if the minimize option is set, minimize the windows before taking the screenshot
    # adding a 5 second sleep after minimizing the windows.
    if args.minimize:
        minimize_all_windows()
        time.sleep(5)
    
    # now take the screenshot
    take_screenshot()
    sys.exit(0)

if __name__ == "__main__":
    main()
    sys.exit(0)

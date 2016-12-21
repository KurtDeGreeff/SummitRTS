#include <ScreenCapture.au3>

$var = WinList()

If $CmdLine[0] = 0 then
   $img = "sg"
Else
   $img = $CmdLine[1]
EndIf   

For $i = 1 to $var[0][0]
	If $var[$i][0] <> "" AND IsVisible($var[$i][1]) Then
		$consoleName = _WinAPI_GetClassName($var[$i][1])
		If $consoleName = "ConsoleWindowClass" Then
			WinSetState($var[$i][1], "", @SW_MINIMIZE)
		EndIf
	EndIf
Next

Func IsVisible($handle)
	If BitAnd( WinGetState($handle) , 2 ) Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

$ImageDir = "c:\device\"

_ScreenCapture_Capture($ImageDir & "Screenshot-" & $img & ".jpg")
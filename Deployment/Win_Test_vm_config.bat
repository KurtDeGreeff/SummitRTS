REM Device Test VM Configuration/deployment Script
REM Vmware Tools should be installed
@echo off
set execdir=%~dp0
cd %execdir%
set admin_pwd=BelayTech2015

goto :MAIN

:get_win_ver
REM Determine the TEST OS family
ver | findstr /i "6\." > nul
IF %ERRORLEVEL% EQU 0 (
	set TESTOS=Win7_fam
	goto :EOF
)
ver | findstr /i "10\." > nul
IF %ERRORLEVEL% EQU 0 (
	set TESTOS=Win10_fam
	goto :EOF
)
set TESTOS=xp_fam
goto :EOF

:create_Device_dir
rem create the c:\device directory
md C:\LocalDropbox
goto :EOF

:Enable_Admin
REM Enable the Administrator Account
Net user administrator /active:yes
goto :EOF

:Admin_Password_Settings
REM Set the password and mark it to never expire
net user administrator %admin_pwd%
net user administrator /EXPIRES:NEVER
goto :EOF

:Auto_login
REM set administrator to log in automatically
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\winlogon" /v DefaultUserName /t REG_SZ /d Administrator /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\winlogon" /v DefaultPassword /t REG_SZ /d %admin_pwd% /f
goto :EOF

:xp_fam
REM nothing to see here
goto :EOF

:Win7_fam
REM disable the UAC
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\policies\system" /v EnableLUA /t REG_DWORD /d 0 /f
goto :EOF

:Win10_fam
REM disable the UAC
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\policies\system" /v EnableLUA /t REG_DWORD /d 0 /f
REM Disable Logon Animation
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f
goto :EOF

:MAIN
call :get_win_ver
call :create_Device_dir
call :Enable_Admin
call :Admin_Password_Settings
call :Auto_login
call :%TESTOS%
call :exit

:exit
exit 0
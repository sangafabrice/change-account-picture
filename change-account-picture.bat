@echo OFF

:Main
: Change the current user picture
: 1=: The asset folder where the different sizes of the
: account picture are located.
: the names of the sized-image files are:
: 32.jpg, 40.jpg, 48.jpg, 64.jpg, 96.jpg, 192.jpg
: 208.jpg, 240.jpg, 424.jpg, 448.jpg, 1080.jpg

PushD "%~dp0"
SetLocal ENABLEDELAYEDEXPANSION

: Copy current sized account
: pictures to variable array IMAGE
Set UAC_PICTURES=%PUBLIC%\AccountPictures
For /F "Tokens=2" %%S In ('Whoami /User /NH') Do (
    Set SID=%%S
    Set SID_DIR=%UAC_PICTURES%\%%S
)
Set Last=-1
For /F "Tokens=*" %%P In ('dir /b /A:s "%SID_DIR%"') Do (
    Set /A Last+=1
    Set IMAGE[!Last!]=%%~nxP
)

: Save the current access rights
: of the account images
Icacls %SID_DIR% /Save %SID%_ACL /Q

: Modify access rights
TakeOwn /F %SID_DIR% /A /R
Icacls %SID_DIR% /Grant:R BUILTIN\Administrators:F /T /Q
Icacls %SID_DIR% /Grant:R %COMPUTERNAME%\%USERNAME%:F /T /Q
Icacls %SID_DIR% /Remove "NT AUTHORITY\SYSTEM" /T /Q
Icacls %SID_DIR% /Remove %COMPUTERNAME%\Administrator /T /Q
Icacls %SID_DIR% /Remove Everyone /T /Q

: Delete all current sized-image files and replace
: them with sized-images from the asset folder [1]
Del /F /S /Q /A:s %SID_DIR%\* 2>&1
For /L %%L In (0,1,%Last%) Do (
    copy /y Assets\!IMAGE[%%L]:~44! %SID_DIR%\!IMAGE[%%L]!
)
Attrib +H +S %SID_DIR%\*.jpg

: Restore access rights
Icacls %SID_DIR% /Setowner "NT AUTHORITY\SYSTEM" /T /Q
Icacls %UAC_PICTURES% /Restore %SID%_ACL /Q
For /L %%L In (0,1,%Last%) Do (
    Icacls %SID_DIR%\!IMAGE[%%L]! /Reset /Q
)
Del /F /Q %SID%_ACL 2> Nul
EndLocal
PopD
@echo off 
if "%1" == "-i" Reg.exe add "HKCU\SOFTWARE\Microsoft\Command Processor" /v "AutoRun" /t REG_SZ /d %~dpnx0 /f

SET PATH=%PATH%;C:\home\bin;C:\home\local\bin;C:\home\proj\win_batch

doskey alias = IF "$1" == "" (doskey /MACROS) ELSE (doskey $*)
doskey cat = type $*
doskey cd = cd /d $*
doskey cdhome = cd %USERPROFILE%
doskey clear = cls
doskey cp = copy $*
doskey env = set $*
doskey history = doskey /history
doskey kill = taskkill /PID $*
doskey ll = dir $* /w
doskey ls = dir $*
doskey mkpubdir = mkdir $* $T IF %%ERRORLEVEL%% EQU 0 icacls $* /inheritance:r ^>nul 2^>^&1 ^& icacls $* /grant Everyone:(OI)(CI)F ^>nul 2^>^&1

doskey mv = move $*
doskey ps = tasklist $*
doskey pwd = cd
doskey rm = del $*

doskey rcopy=if "$2"=="" (echo Usage: rcopy SRC DST) else robocopy "$1" "$2" /E /SJ /SL /MT:32 /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NP
doskey rsync=if "$2"=="" (echo Usage: rsync SRC DST) else robocopy "$1" "$2" /MIR /SJ /SL /MT:32 /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NP
doskey fdel=if "$1"=="" (echo Usage: fdel DIR1 [DIR2 ...]) else C:\home\local\FastCopy\fcp.exe /cmd=delete /force_close /no_ui /estimate=FALSE /speed=fullspeed $*
doskey ncat=c:\home\local\nmap\ncat.exe -w 1 $*
doskey nc=c:\home\local\nmap\ncat.exe -w 1 $*

doskey notepad="C:\home\local\npp\notepad++.exe" $*
doskey vi="C:\home\local\npp\notepad++.exe" $*
doskey nvm = IF "$1" == "use" (nvmuse $2 $3 $4) ELSE (nvm $*)

IF NOT EXIST c:\windows\system32\sudo.exe doskey sudo=c:\usr\bin\gsudo.exe $*
IF EXIST C:\home\android\platform-tools\adb.exe doskey adb=C:\home\android\platform-tools\adb.exe $*

:: doskey ktboot  = cmd /c "gsudo bcdedit.exe /set {fwbootmgr} default {bb0223c0-5d5d-11f0-afe1-806e6f6e6963} && IF /i "$1" == "/r" (shutdown /r /t 0) ELSE IF /i "$1" == "/p" (shutdown /p /t 0)"
:: doskey rnbboot = cmd /c "gsudo bcdedit.exe /set {fwbootmgr} default {bb0223c1-5d5d-11f0-afe1-806e6f6e6963} && IF /i "$1" == "/r" (shutdown /r /t 0) ELSE IF /i "$1" == "/p" (shutdown /p /t 0)"

doskey ktboot=cmd /c "IF /i \"$1\"==\"/o\" (gsudo bcdedit.exe /bootsequence {bb0223c0-5d5d-11f0-afe1-806e6f6e6963} && shutdown /r /t 0) ELSE (gsudo bcdedit.exe /set {fwbootmgr} default {bb0223c0-5d5d-11f0-afe1-806e6f6e6963} && IF /i \"$1\"==\"/r\" (shutdown /r /t 0) ELSE IF /i \"$1\"==\"/p\" (shutdown /s /t 0))"
doskey rnbboot=cmd /c "IF /i \"$1\"==\"/o\" (gsudo bcdedit.exe /bootsequence {bb0223c1-5d5d-11f0-afe1-806e6f6e6963} && shutdown /r /t 0) ELSE (gsudo bcdedit.exe /set {fwbootmgr} default {bb0223c1-5d5d-11f0-afe1-806e6f6e6963} && IF /i \"$1\"==\"/r\" (shutdown /r /t 0) ELSE IF /i \"$1\"==\"/p\" (shutdown /s /t 0))"

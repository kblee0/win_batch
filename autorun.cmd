@echo off 
SET PATH=%PATH%;C:\home\bin;C:\home\local\bin;C:\home\proj\win_batch

doskey alias = doskey $*
doskey cat = type $*
doskey cd = cd /d $*
doskey clear = cls
doskey cp = copy $*
doskey history = doskey /history
doskey kill = taskkill /PID $*
doskey ll = dir $* /w
doskey ls = dir $*
doskey mkpubdir = mkdir $* $T IF %%ERRORLEVEL%% EQU 0 icacls $* /inheritance:r ^>nul 2^>^&1 ^& icacls $* /grant Everyone:(OI)(CI)F ^>nul 2^>^&1

doskey mv = move $*
doskey ps = tasklist $*
doskey pwd = cd
doskey rm = del $*

doskey rcopy=robocopy $* /E /SJ /SL /MT /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL
doskey rsync=robocopy $* /MIR /E /SJ /SL /MT /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL

doskey notepad="C:\home\local\npp\notepad++.exe" $*
doskey vi="C:\home\local\npp\notepad++.exe" $*

IF NOT EXIST c:\windows\system32\sudo.exe doskey sudo=c:\usr\bin\gsudo.exe $*
IF EXIST C:\home\android\platform-tools\adb.exe doskey adb=C:\home\android\platform-tools\adb.exe $*

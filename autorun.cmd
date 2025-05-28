@echo off 
doskey ls=dir $*
doskey cat=type $*
doskey cd=cd /d $*
doskey notepad="C:\home\local\npp\notepad++.exe" $*
doskey rcopy=robocopy $1 $2 /E /SJ /SL /MT /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL $3 $4 $5 $6 $7 $8 $9
doskey rsync=robocopy $1 $2 /E /SJ /SL /MIR /MT /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL $3 $4 $5 $6 $7 $8 $9
doskey history=doskey /history

IF NOT EXIST c:\windows\system32\sudo.exe doskey sudo=c:\usr\bin\gsudo.exe $*
IF EXIST C:\home\android\platform-tools\adb.exe doskey adb=C:\home\android\platform-tools\adb.exe $*

SET PATH=%PATH%;C:\home\bin;C:\home\local\bin;C:\home\proj\win_batch

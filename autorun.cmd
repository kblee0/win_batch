@echo off 
doskey ls=dir $*
doskey cat=type $*
doskey cd=cd /d $*
doskey fcp=C:\usr\local\FastCopy\fcp.exe $*
doskey notepad="C:\home\local\npp\notepad++.exe" $*
IF NOT EXIST c:\windows\system32\sudo.exe doskey sudo=c:\usr\bin\gsudo.exe $*
IF EXIST C:\home\android\platform-tools\adb.exe doskey adb=C:\home\android\platform-tools\adb.exe $*
@echo on 

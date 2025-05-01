@echo off
setlocal

SET PATH=%~dp0;%PATH%

SET FCP=fcp /cmd=sync /log=FALSE /ini=nul /filelog=nul

set ARGC=0
for %%x in (%*) do set /A ARGC+=1

IF %ARGC% EQU 0 call :help

IF %ARGC% EQU 3 IF /i "%1" == "biz" call :backup_biz %2 %3

IF %ARGC% EQU 3 IF /i "%1" == "all" call :backup_all %2 %3

goto :end

:help
echo.
echo Usage: sync.bat ^<mode^> ^<source^> ^<target^>
echo.
echo mode:
echo    biz: biz backup
echo    all: backup
exit /b
goto:eof

:backup_biz
call :fcp_sync %1\Users\kblee\AppData\LocalLow\NPKI       %2\Users\kblee\AppData\LocalLow\NPKI
call :fcp_sync %1\Users\kblee\AppData\Roaming\Postman     %2\Users\kblee\AppData\Roaming\Postman
call :fcp_sync %1\Users\kblee\AppData\Roaming\DBeaverData %2\Users\kblee\AppData\Roaming\DBeaverData
call :fcp_sync %1\Users\kblee\AppData\Roaming\JetBrains   %2\Users\kblee\AppData\Roaming\JetBrains
call :fcp_sync %1\usr                                     %2\usr                                     "/exclude=\local\utorrent\;\local\hitomi_downloader\;\serial.rar"
call :fcp_sync %1\home                                    %2\home                                    "/exclude=\game\"
call :fcp_sync %1\opt                                     %2\opt                                     "/exclude=\KTDecryptor\;\ventoy\"

goto:eof


:backup_all
call :fcp_sync %1\Users\kblee\AppData\LocalLow\NPKI       %2\Users\kblee\AppData\LocalLow\NPKI
call :fcp_sync %1\Users\kblee\AppData\Roaming\Postman     %2\Users\kblee\AppData\Roaming\Postman
call :fcp_sync %1\Users\kblee\AppData\Roaming\DBeaverData %2\Users\kblee\AppData\Roaming\DBeaverData
call :fcp_sync %1\Users\kblee\AppData\Roaming\JetBrains   %2\Users\kblee\AppData\Roaming\JetBrains
call :fcp_sync %1\usr                                     %2\usr
call :fcp_sync %1\home                                    %2\home
call :fcp_sync %1\opt                                     %2\opt

goto:eof

:fcp_sync
dir /b %1 >nul 2>nul
If Not %ERRORLEVEL% EQU 0 goto:eof

%FCP% %3 %4 %5 "%1" "/to=%2"

goto:eof

:end
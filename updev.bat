@echo off
setlocal
SET PATH=%~dp0;%PATH%

SET FCP=fcp /cmd=sync /log=FALSE /ini=nul /filelog=nul

IF "%1" == "%2" goto :help

call :devprojbackup %1 %2 IntelliJ
call :devprojbackup %1 %2 DataGrip
call :devprojbackup %1 %2 PyCharm
call :devprojbackup %1 %2 WebStorm
call :devprojbackup %1 %2 Fleet
call :devprojbackup %1 %2 DBeaver
call :devprojbackup %1 %2 vscode "/exclude=\data\user-data\;\data\argv.json"

goto :end

:help
echo.
echo Usage: upddev.bat ^<source^> ^<target^>
EXIT /B

goto :eof

:devprojbackup
IF "%3" == "" goto :eof

SET SRC=%1
SET TGT=%2
SET PROD=%3
SET EXCLUDE=%4

SET PROD_HOME=\home\dev\%PROD%
SET PROD_INFO=%PROD_HOME%\product-info.json

IF EXIST %SRC%%PROD_INFO% FOR /F %%i IN ('jq -r .dataDirectoryName %SRC%%PROD_INFO%') DO SET APP_PLUGINS=\Users\kblee\AppData\Roaming\JetBrains\%%i\plugins
IF EXIST %SRC%%PROD_INFO% SET JDBC_DRIVERS=\Users\kblee\AppData\Roaming\JetBrains\%%i\jdbc-drivers

IF EXIST %SRC%%APP_PLUGINS% %FCP% "%SRC%%APP_PLUGINS%" "/to=%TGT%%APP_PLUGINS%"
REM IF EXIST %SRC%%JDBC_DRIVERS% %FCP% "%SRC%%JDBC_DRIVERS%" "/to=%TGT%%JDBC_DRIVERS%"

IF EXIST %SRC%%PROD_HOME% %FCP% %EXCLUDE% "%SRC%%PROD_HOME%" "/to=%TGT%%PROD_HOME%"

goto :eof

:end
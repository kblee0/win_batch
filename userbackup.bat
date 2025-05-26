@echo off
:: APPDATA=C:\Users\kblee\AppData\Roaming
:: LOCALAPPDATA=C:\Users\kblee\AppData\Local
:: USERPROFILE=C:\Users\kblee

SET BAK=D:\backup


:: IF EXIST %SystemDrive%\home mkdir %BAKBASE%\home
:: IF EXIST %SystemDrive%\home robocopy %SystemDrive%\home %BAKBASE%\home /MT /E /R:1 /W:1 /SJ /SL

IF /i "%1" == "backup" for %%d in (C:\down c:\img %SystemDrive%\home %USERPROFILE%\Desktop %USERPROFILE%\Downloads %APPDATA%\Postman %USERPROFILE%\AppData\LocalLow\NPKI) DO call :robocopy_backup %%d
IF /i "%1" == "restore" call :mkdir_everyone c:\home
IF /i "%1" == "restore" call :mkdir_everyone c:\down
IF /i "%1" == "restore" call :mkdir_everyone c:\img
IF /i "%1" == "restore" for %%d in (C:\down c:\img %SystemDrive%\home %USERPROFILE%\Desktop %USERPROFILE%\Downloads %APPDATA%\Postman %USERPROFILE%\AppData\LocalLow\NPKI) DO call :robocopy_restore %%d

EXIT /B

:robocopy_backup
SET SRC=%1
call SET "DST=%%SRC:%SystemDrive%=%BAK%%%"

IF NOT EXIST %SRC% goto :eof

mkdir %DST%
robocopy %SRC% %DST% /MT /E /R:1 /W:1 /SJ /SL /NFL

goto :eof


:robocopy_restore
SET SRC=%1
call SET "DST=%%SRC:%SystemDrive%=%BAK%%%"

IF NOT EXIST %SRC% goto :eof

mkdir %SRC%
robocopy %DST% %SRC% /MT /E /R:1 /W:1 /SJ /SL /NFL

goto :eof

:mkdir_everyone
SET DIR=%1
mkdir %DIR%
IF %ERRORLEVEL% NEQ 0 goto :eof
:: 기존 상속 제거하고 권한 초기화
icacls %DIR% /inheritance:r
:: Everyone에게 모든 권한 부여
icacls %DIR% /grant Everyone:(OI)(CI)F

goto :eof

:: IF EXIST  %USERPROFILE%\Desktop mkdir %BAKBASE%\Desktop
:: IF EXIST  %USERPROFILE%\Desktop robocopy %USERPROFILE%\Desktop %BAKBASE%\Desktop /MT /E /R:1 /W:1 /SJ /SL
:: 
:: IF EXIST %APPDATA%\Postman mkdir %BAKBASE%\Postman
:: IF EXIST %APPDATA%\Postman robocopy %APPDATA%\Postman %BAKBASE%\Postman /MT /E /R:1 /W:1 /SJ /SL
:: 
:: mkdir %BAKBASE%\NPKI
:: robocopy %USERPROFILE%\AppData\LocalLow\NPKI %BAKBASE%\NPKI /MT /E /R:1 /W:1 /SJ /SL

:: /E :: 비어 있는 디렉터리를 포함하여 하위 디렉터리를 복사합니다.
:: /PURGE :: 원본에 없는 대상 파일/디렉터리를 삭제합니다.
:: /MIR :: 디렉터리 트리를 미러링합니다. /E와 /PURGE를 함께 쓰는 것과 동일합니다.
:: /XJ:: 파일 및 디렉터리 모두에 대한 바로 가기 링크 및 접합 지점을 제외합니다.:: /SJ:: 접합을 접합 대상으로 복사하는 대신 접합으로 복사합니다.
:: /SL:: 바로 가기 링크를 링크 대상으로 복사하는 대신 링크로 복사합니다.
:: /COMPRESS :: 파일을 전송하는 동안 네트워크 압축을 요청합니다(해당하는 경우).
:: /R:n :: 실패한 복사본에 대한 다시 시도 횟수입니다. 기본값은 1백만입니다.
:: /W:n :: 다시 시도 간 대기 시간입니다. 기본값은 30초입니다.
:: /NFL :: 파일 목록 없음 - 파일 이름을 기록하지 않습니다.
:: /NDL :: 디렉터리 목록 없음 - 디렉터리 이름을 기록하지 않습니다.
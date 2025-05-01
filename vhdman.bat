@echo off
setlocal
setlocal enabledelayedexpansion

for %%i in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF "!HLOCAL!" == "" IF EXIST %%i:\home\local SET HLOCAL=%%i:\home\local

SET DSCR=C:\img\vhdman.scr

IF NOT "%1" == "" SET VHD=%1
IF "%1" == "" SET VHD=C:\img\win11_base.vhdx

goto :check_admin
 
:main
cls

echo --------------------------------------------------------------------------
echo  VHD : %VHD%
echo --------------------------------------------------------------------------
echo.
echo  0. Exit                          99. Reboot
echo.
echo  1. VHD 파일 선택                  2. VHD 생성 및 NTFS포맷
echo  3. VHD 압축                       4. Child VHD 생성
echo.
echo --------------------------------------------------------------------------
echo.


set menunum=
set /p menunum="기능을 선택하세요: "

If "%menunum%" EQU "0" Exit /B

call :mainmenu_%menunum%
goto :main

:mainmenu_99
shutdown /r /t 0
goto:eof

:mainmenu_1

SET /p VHD="VHD 파일명: "

goto:eof

:mainmenu_2

SET /p VHD="VHD 파일명: "
SET /p SZGB="Size (GB): "
SET /a SZMB=%SZGB% * 1024

IF EXIST %VHD% SET /P YN="파일이 존재합니다. 그래도 생성하시겠습니까? (Y/N): "
IF EXIST %VHD% IF /I NOT "%YN%" == "Y" goto:eof

(
echo create vdisk file="%VHD%" type=expandable maximum=%SZMB%
echo select vdisk file="%VHD%"
echo attach vdisk
echo create partition primary
echo format fs=ntfs quick
echo detach vdisk

) > %DSCR%
diskpart /s %DSCR%
del %DSCR%

pause

goto:eof


:mainmenu_3

(
echo select vdisk file="%VHD%"
echo detach vdisk
) > %DSCR%
diskpart /s %DSCR%
del %DSCR%


(
echo select vdisk file="%VHD%"
echo attach vdisk
echo select partition 1
echo assign letter=V
) > %DSCR%

diskpart /s %DSCR%
del %DSCR%

%HLOCAL%\bin\sdelete64.exe /z V:

(
echo select vdisk file="%VHD%"
echo detach vdisk
echo compact vdisk
) > %DSCR%

diskpart /s %DSCR%
del %DSCR%

pause

goto:eof

:mainmenu_4

SET /p CVHD="Child VHD 파일명: "

IF EXIST %CVHD% SET /P YN="파일이 존재합니다. 그래도 생성하시겠습니까? (Y/N): "
IF EXIST %CVHD% IF /I NOT "%YN%" == "Y" goto:eof

(
echo select vdisk file="%VHD%"
echo detach vdisk
) > %DSCR%
diskpart /s %DSCR%
del %DSCR%

(
echo create vdisk file="%CVHD%" parent="%VHD%"
) > %DSCR%

diskpart /s %DSCR%
del %DSCR%

pause

goto:eof


:check_admin
Reg.exe query "HKU\S-1-5-19\Environment"
If Not %ERRORLEVEL% EQU 0 (
 Echo You must have administrator rights to continue ... 
 Exit /B																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																					
)
goto :main

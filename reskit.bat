@echo off
setlocal
setlocal enabledelayedexpansion

for %%i in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF "!HLOCAL!" == "" IF EXIST %%i:\home\local SET HLOCAL=%%i:\home\local

goto :check_admin
 
:main
cls

echo --------------------------------------------------------------------------
echo  0. Exit                          99. Reboot
echo.
echo  1. 키보드 속도 빠르게 설정        2. 한영전환 Shift-Space, 한글 동시지원
echo  3. 다운로드 Savezone 비활성화
echo.
echo * Windows 설정
echo  4. 위젯 비활성화 (11)             5. CoPilot 비활성화 (11)
echo  6. 백그라운드앱 중지              7. Explorer 기본설정
echo  8. Hostname/Workgroup 변경        9. 예약된 저장소 삭제
echo 10. Windows App 삭제              11. TEMP 변경
echo 12. cmd process 설정(autorun.cmd) 13. 기본 임시디렉토리 오픈
echo 14. PC시간을 UTC 로설정
echo.
echo * 기타
echo 15. 드라이브백업                  16. 드라이브복원
echo 17. Win11 Setup check bypass      18. 인터넷 연결없이 설치
echo 19. 업데이트 백업파일 제거        20. Bluetooth Keys Regedit
echo 21. Office 2024 KMS인증
echo.
echo --------------------------------------------------------------------------
echo.
set menunum=
set /p menunum="기능을 선택하세요: "

If 0%menunum% EQU 0 Exit /B

call :mainmenu_%menunum%
goto :main

:mainmenu_99
shutdown /r /t 0
goto:eof

:mainmenu_1
echo 키보드 속도 빠르게 설정
Reg.exe add "HKCU\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2" /f
Reg.exe add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f
Reg.exe add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f

pause
goto:eof

:mainmenu_2
echo 한영전환 Shift-Space, 한글 동시지원
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters" /v "LayerDriver KOR" /t REG_SZ /d "kbd101c.dll" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters" /v "OverrideKeyboardIdentifier" /t REG_SZ /d "PCAT_101CKEY" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters" /v "OverrideKeyboardSubtype" /t REG_DWORD /d "5" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters" /v "OverrideKeyboardType" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /t REG_BINARY /d "000000000000000003000000720038E071001DE000000000" /f

pause
goto:eof

:mainmenu_3
echo 다운로드 Savezone 비활성화
REM ; 다운로드하는 파일의 보안 정보 저장
REM ; 0이면 저장, 1이면 저장 안 함.
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d "1" /f

pause
goto:eof

:mainmenu_4
echo 위젯 비활성화
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f

pause
goto:eof

:mainmenu_5
echo CoPilot 비활성화
Reg.exe add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d "1" /f

pause
goto:eof

:mainmenu_6
echo 백그라운드앱 중지
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRuninBackgroud" /t REG_DWORD /d "2" /f

pause
goto:eof

:mainmenu_7
echo Explorer 기본설정
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "NavPaneShowAllFolders" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "NavPaneExpandToCurrentFolder" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableSnapBar" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SnapAssist" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_IrisRecommendations" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_Layout" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" /v "ShowFrequentList" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" /v "ShowRecentList" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v "TaskbarEndTask" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecommendations" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowCloudFilesInQuickAccess" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "1" /f

taskkill /F /IM explorer.exe
explorer.exe

pause
goto:eof

:mainmenu_8
set /p hostname="HOSTNAME: "
set /p workgroup="WORKGROUP: "

powershell -c "Add-Computer -WorkGroupName %workgroup%"
powershell -c "Rename-Computer -NewName %hostname%"

pause
goto:eof

:mainmenu_9
DISM.exe /Online /Set-ReservedStorageState /State:Disabled

pause
goto:eof

:mainmenu_10

SET APPS=^
'Clipchamp.Clipchamp', ^
'Microsoft.549981C3F5F10', ^
'Microsoft.BingNews', ^
'Microsoft.BingWeather', ^
'Microsoft.GamingApp', ^
'Microsoft.GetHelp', ^
'Microsoft.Getstarted', ^
'Microsoft.MicrosoftOfficeHub', ^
'Microsoft.MicrosoftSolitaireCollection', ^
'Microsoft.MicrosoftStickyNotes', ^
'Microsoft.People', ^
'Microsoft.PowerAutomateDesktop', ^
'Microsoft.Todos', ^
'Microsoft.Windows.Photos', ^
'Microsoft.WindowsAlarms', ^
'Microsoft.WindowsCamera', ^
'Microsoft.WindowsFeedbackHub', ^
'Microsoft.WindowsMaps', ^
'Microsoft.WindowsSoundRecorder', ^
'Microsoft.Xbox.TCUI', ^
'Microsoft.YourPhone', ^
'Microsoft.ZuneMusic', ^
'Microsoft.ZuneVideo', ^
'MicrosoftCorporationII.QuickAssist', ^
'microsoft.windowscommunicationsapps', ^
'Microsoft.OutlookForWindows', ^
'MicrosoftCorporationII.MicrosoftFamily', ^
'MSTeams', ^
'Microsoft.Copilot', ^
'Microsoft.BingNews', ^
'Microsoft.BingSearch', ^
'Microsoft.BingWeather', ^
'Microsoft.Office.OneNote', ^
'Microsoft.SkypeApp', ^
'Microsoft.ZuneMusic', ^
'Microsoft.ZuneVideo', ^
'Microsoft.Microsoft3DViewer', ^
'Microsoft.MicrosoftOfficeHub', ^
'Microsoft.MicrosoftSolitaireCollection', ^
'Microsoft.MixedReality.Portal', ^
'Microsoft.BingWeather', ^
'Microsoft.WindowsMaps', ^
'7EE7776C.LinkedInforWindows'

powershell -Command "Get-AppxPackage -AllUsers | Where-Object { $_.Name -in @( %APPS% ) } | Remove-AppxPackage"


REM Microsoft.WindowsMaps
REM sc delete MapsBroker
REM sc delete lfsvc
REM schtasks /Change /TN "\Microsoft\Windows\Maps\MapsUpdateTask" /disable
REM schtasks /Change /TN "\Microsoft\Windows\Maps\MapsToastTask" /disable
REM Remove Package
REM Get-AppxPackage -allusers *Microsoft.Office.Sway* | Remove-AppxPackage
REM Get-AppxPackage -allusers *Microsoft.Office.Desktop* | Remove-AppxPackage
REM Get-AppxPackage -allusers MicrosoftTeams | Remove-AppxPackage
REM Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage
REM Get-AppxPackage -AllUsers *onenote* | Remove-AppxPackage
REM Get-AppxPackage -AllUsers Disney.37853FC22B2CE  | Remove-AppxPackage
REM Get-AppxPackage -AllUsers *SkypeApp* | Remove-AppxPackage
REM Get-AppxPackage -AllUsers *SpotifyAB.SpotifyMusic* | Remove-AppxPackage
REM Get-AppxPackage -AllUsers *xbox* | Remove-AppxPackage
REM sc delete XblAuthManager
REM sc delete XblGameSave
REM sc delete XboxNetApiSvc
REM sc delete XboxGipSvc
REM reg delete "HKLM\SYSTEM\CurrentControlSet\Services\xbgm" /f
REM schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /disable
REM schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /disable
REM reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f
pause
goto:eof

:mainmenu_11
set /p tmpdir="디렉토리: "
IF NOT EXIST "%tmpdir%" mkdir "%tmpdir%"
Reg.exe DELETE HKCU\Environment /v TEMP /f
Reg.exe DELETE HKCU\Environment /v TMP /f
setx TEMP "%tmpdir%" /m
setx TMP "%tmpdir%" /m

pause
goto:eof

:mainmenu_12
IF EXIST C:\home\proj\win_batch\autorun.cmd Reg.exe add "HKLM\SOFTWARE\Microsoft\Command Processor" /v "AutoRun" /t REG_SZ /d "C:\home\proj\win_batch\autorun.cmd" /f

pause
goto:eof


:mainmenu_13
start %SystemRoot%\TEMP
start %USERPROFILE%\AppData\Local\Temp

pause
goto:eof


:mainmenu_14
echo PC시간을 UTC 로설정
Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d "1" /f

pause
goto:eof

:mainmenu_15
set /p DRVDIR="디렉토리: "
IF NOT EXIST "%DRVDIR%" mkdir "%DRVDIR%"
Dism.exe /Online /Export-Driver "/Destination:%DRVDIR%"

pause
goto:eof

:mainmenu_16
set /p DRVDIR="디렉토리: "
pnputil.exe /add-driver "%DRVDIR%\*.inf" /subdirs /install
start devmgmt.msc

pause
goto:eof

:mainmenu_17
Reg.exe add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f

pause
goto:eof

:mainmenu_18
Reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /v BypassNRO /t REG_DWORD /d 1 /f

pause
goto:eof


:mainmenu_19
dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

pause
goto:eof

:mainmenu_20

%HLOCAL%\bin\psexec.exe -i -s %HLOCAL%\bin\regjump.exe HKLM\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters

goto:eof

:mainmenu_21
SET INET_HST=kms.digiboy.ir

SET /P IN_HST="KMS Host (INET:%INET_HST% -> 127.0.0.1): "

IF "%IN_HST%" == "" EXIT /B
SET HST=%IN_HST%
IF /i "%IN_HST%" == "INET" SET HST=%INET_HST%

cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /remhst
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /sethst:%HST%
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /dstatus
IF /i "%IN_HST%" == "INET" cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /sethst:127.0.0.1
pause

goto:eof


:check_admin
Reg.exe query "HKU\S-1-5-19\Environment"
If Not %ERRORLEVEL% EQU 0 (
 Echo You must have administrator rights to continue ... 
 Exit /B																									
)
goto :main

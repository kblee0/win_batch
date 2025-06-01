@echo off
setlocal enabledelayedexpansion

:check_admin
net session >nul 2>&1
if %errorlevel% neq 0 (
	if exist %SystemRoot%\system32\sudo.exe (
		sudo --inline %~f0
	) else (
		Echo You must have administrator rights to continue ...
	)
	Exit /B																									
)

for %%i in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF "!HOME!" == "" IF EXIST %%i:\home SET HOME=%%i:\home

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
echo 12. Terminal 기본설정             13. 기본 임시디렉토리 오픈
echo 14. PC시간을 UTC 로설정
echo.
echo * 기타
echo 15. 드라이브백업                  16. 드라이브복원
echo 17. Win11 Setup check bypass      18. 인터넷 연결없이 설치
echo 19. 업데이트 백업파일 제거        20. Bluetooth Keys Regedit
echo.
echo * 인증
echo 21. Windows 10/11 Pro KMS인증     22. Office KMS인증
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
:: 다운로드하는 파일의 보안 정보 저장
:: 0이면 저장, 1이면 저장 안 함.
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
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "AutoCheckSelect" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" /v "ShowFrequentList" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" /v "ShowRecentList" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v "TaskbarEndTask" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecommendations" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowCloudFilesInQuickAccess" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "1" /f


:: zip/cap folder disable
Reg.exe delete "HKCR\CABFolder\CLSID" /f
Reg.exe delete "HKCR\CompressedFolder\CLSID" /f
Reg.exe delete "HKCR\SystemFileAssociations\.cab\CLSID" /f
Reg.exe delete "HKCR\SystemFileAssociations\.zip\CLSID" /f
for %%i in (.7z .bz2 .gz .rar .tar .tbz2 .tgz .txz .tzst .xz .zst) do Reg.exe delete "HKCR\SystemFileAssociations\%%i\CLSID" /f

:: zip/cap folder enable
:: Reg.exe add "HKCR\CABFolder\CLSID" /ve /t REG_SZ /d "{0CD7A5C0-9F37-11CE-AE65-08002B2E1262}" /f
:: Reg.exe add "HKCR\CompressedFolder\CLSID" /ve /t REG_SZ /d "{E88DCCE0-B7B3-11d1-A9F0-00AA0060FA31}" /f
:: Reg.exe add "HKCR\SystemFileAssociations\.cab\CLSID" /ve /t REG_SZ /d "{0CD7A5C0-9F37-11CE-AE65-08002B2E1262}" /f
:: Reg.exe add "HKCR\SystemFileAssociations\.zip\CLSID" /ve /t REG_SZ /d "{E88DCCE0-B7B3-11d1-A9F0-00AA0060FA31}" /f
:: for %%i in (.7z .bz2 .gz .rar .tar .tbz2 .tgz .txz .tzst .xz .zst) do echo Reg.exe add "HKCR\SystemFileAssociations\%%i\CLSID" /ve /t REG_SZ /d "{0C1FD748-B888-443D-9EC3-AD7E22D48808}" /f

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


:: Microsoft.WindowsMaps
:: sc delete MapsBroker
:: sc delete lfsvc
:: schtasks /Change /TN "\Microsoft\Windows\Maps\MapsUpdateTask" /disable
:: schtasks /Change /TN "\Microsoft\Windows\Maps\MapsToastTask" /disable
:: Remove Package
:: Get-AppxPackage -allusers *Microsoft.Office.Sway* | Remove-AppxPackage
:: Get-AppxPackage -allusers *Microsoft.Office.Desktop* | Remove-AppxPackage
:: Get-AppxPackage -allusers MicrosoftTeams | Remove-AppxPackage
:: Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage
:: Get-AppxPackage -AllUsers *onenote* | Remove-AppxPackage
:: Get-AppxPackage -AllUsers Disney.37853FC22B2CE  | Remove-AppxPackage
:: Get-AppxPackage -AllUsers *SkypeApp* | Remove-AppxPackage
:: Get-AppxPackage -AllUsers *SpotifyAB.SpotifyMusic* | Remove-AppxPackage
:: Get-AppxPackage -AllUsers *xbox* | Remove-AppxPackage
:: sc delete XblAuthManager
:: sc delete XblGameSave
:: sc delete XboxNetApiSvc
:: sc delete XboxGipSvc
:: reg delete "HKLM\SYSTEM\CurrentControlSet\Services\xbgm" /f
:: schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /disable
:: schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /disable
:: reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f
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
:: IF EXIST C:\home\proj\win_batch\autorun.cmd Reg.exe add "HKCU\SOFTWARE\Microsoft\Command Processor" /v "AutoRun" /t REG_SZ /d "C:\home\proj\win_batch\autorun.cmd" /f
SET JQ=%HOME%\bin\jq.exe
SET JSON=%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

IF NOT EXIST %JQ% goto :eof
IF NOT EXIST %JSON% goto :eof

(
echo .copyOnSelect = true ^|
echo .defaultProfile = (.profiles.list[] ^| select(.name == "\uba85\ub839 \ud504\ub86c\ud504\ud2b8" or .name == "Command Prompt"^) ^| .guid ^) ^|
echo .profiles.defaults = {"font": {"face": "Monoplex KR"}} ^|
echo .profiles.list ^|= map(if .guid == "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}" then
::echo     .commandline = "%%SystemRoot%%\\System32\\cmd.exe /k C:\\home\\autorun.cmd" ^| .startingDirectory = "C:\\home"
echo     .startingDirectory = "C:\\home"
echo  else . end^) ^|
echo .profiles.list = (
echo    [.profiles.list[] ^| select(.name == "\uba85\ub839 \ud504\ub86c\ud504\ud2b8" or .name == "Command Prompt"^)] +
echo    [.profiles.list[] ^| select(.name ^^!= "\uba85\ub839 \ud504\ub86c\ud504\ud2b8" and .name ^^!= "Command Prompt"^)]
echo ^)
) > %TEMP%\temp.jq

%JQ% -f %TEMP%\temp.jq %JSON% > %TEMP%\temp.json
copy %TEMP%\temp.json %JSON%

del %TEMP%\temp.jq
del %TEMP%\temp.json

Reg.exe add "HKCU\Console\%%%%Startup" /v "DelegationConsole" /t REG_SZ /d "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}" /f
Reg.exe add "HKCU\Console\%%%%Startup" /v "DelegationTerminal" /t REG_SZ /d "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}" /f

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

%HOME%\local\bin\psexec.exe -i -s %HLOCAL%\bin\regjump.exe HKLM\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters

goto:eof

:mainmenu_21
SET INET_HST=kms.digiboy.ir

SET /P IN_HST="KMS Host (INET:%INET_HST% -> 127.0.0.1): "

IF "%IN_HST%" == "" goto:eof
SET HST=%IN_HST%
IF /i "%IN_HST%" == "INET" SET HST=%INET_HST%

cscript %SystemRoot%\System32\slmgr.vbs /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
cscript %SystemRoot%\System32\slmgr.vbs /skms %HST%
cscript %SystemRoot%\System32\slmgr.vbs /ato

pause

goto:eof

:mainmenu_22
SET INET_HST=kms.digiboy.ir

SET /P IN_HST="KMS Host (INET:%INET_HST% -> 127.0.0.1): "

IF "%IN_HST%" == "" goto:eof
SET HST=%IN_HST%
IF /i "%IN_HST%" == "INET" SET HST=%INET_HST%

cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /remhst
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /sethst:%HST%
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /dstatus
IF /i "%IN_HST%" == "INET" cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /sethst:127.0.0.1
pause

goto:eof

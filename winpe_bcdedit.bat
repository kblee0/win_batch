@echo off
goto :main
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

:main

set /p wim=Enter the path of the boot.wim file:

for %%I in ("%wim%") do set "DRV=%%~dI"
for %%I in ("%wim%") do set "PTH=%%~pI"
for %%I in ("%wim%") do set "FNM=%%~nxI"

:: 참고: https://cappleblog.tistory.com/103
:: {ramdiskoptions} 항목을 생성합니다. 이 때 /d 의 내용은 없앨 것이기에 대충 설정하셔도 됩니다.
:: bcdedit /enum {ramdiskoptions} 명령으로 설정 확인
bcdedit /create {ramdiskoptions} /d "Ramdisk Options"
:: 준비된 boot.sdi 파일의 전체 경로에 맞춰 전체 장치 경로를 설정합니다.
bcdedit /set {ramdiskoptions} ramdisksdidevice partition=%DRV%
bcdedit /set {ramdiskoptions} ramdisksdipath %PTH%boot.sdi
bcdedit /deletevalue {ramdiskoptions} description

for /f %%i in ('bcdedit /create /d "Windows PE" /application osloader') DO set GUID=%%i
bcdedit /create /d "Windows PE" /application osloader
bcdedit /set %GUID% device ramdisk=[%DRV%]%PTH%%FNM%,{ramdiskoptions}
bcdedit /set %GUID% path \windows\system32\winload.efi
bcdedit /set %GUID% description "Windows PE"
bcdedit /set %GUID% locale "ko-kr"
bcdedit /set %GUID% osdevice ramdisk=[%DRV%]%PTH%%FNM%,{ramdiskoptions}
bcdedit /set %GUID% systemroot \windows
bcdedit /set %GUID% winpe yes
bcdedit /set %GUID% nx OptIn
bcdedit /set %GUID% detecthal yes
bcdedit /displayorder %GUID% /addlast

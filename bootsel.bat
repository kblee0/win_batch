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

set "identifier="
set "description="
set "device="
set /a index=1

:main
cls
echo ========================================================================
echo  No    Description                    Device
echo ========================================================================

for /f "tokens=1,* delims= " %%A in ('bcdedit') do (
    set "key=%%A"
    set "value=%%B"

    if /i "!key!"=="identifier" (
        set "identifier=!value!"
    ) else if /i "!key!"=="description" (
        set "description=!value!"
    ) else if /i "!key!"=="device" (
        set "device=!value!"
    )

    if defined identifier if defined description if defined device (
        if /i not "!identifier!"=="{bootmgr}" if /i not "!description!"=="Windows Boot Manager" (
            call :PrintAligned !index! "!description!" "!device!"
			set "id[!index!]=!identifier!"
            set /a index+=1
        )
        set "identifier="
        set "description="
        set "device="
    )
)

echo.
set /p choice="기본 부팅 항목 No : "

if not defined id[%choice%] (
    echo 해당 No에 해당하는 부팅 항목이 없습니다.
    goto :eof
)

set "selectedID=!id[%choice%]!"

echo 선택된 ID(!selectedID!)를 기본 부팅 항목으로 설정 중...
bcdedit /default !selectedID! >nul 2>&1

if %errorlevel% neq 0 (
    echo 오류: bcdedit 기본 부팅 항목 설정 실패.
    goto :eof
)

echo 성공적으로 설정되었습니다.

echo.
CHOICE /T 5 /N /C yn /D n /M "5초 후 재부팅 합니다. 취소하시겠습니까? (Y/N): "

if %errorlevel% equ 1 (
	echo 재부팅이 취소 되었습니다.
	goto :eof
)

echo 재부팅을 시작합니다.
shutdown /r /t 0

goto :eof

:PrintAligned
:: %1=index, %2=description, %3=device
set "idx=  %1"
set "desc=%~2"
set "dev=%~3"

:: 패딩
set "pad=                              "  :: 30칸
set "idx=!idx:~-2!"                     :: 오른쪽 정렬 (3자리)
set "desc=!desc!!pad!"
set "desc=!desc:~0,30!"                :: description: 최대 30자

echo  !idx!.   !desc! !dev!
goto :eof

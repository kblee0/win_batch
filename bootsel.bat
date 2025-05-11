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
set /p choice="�⺻ ���� �׸� No : "

if not defined id[%choice%] (
    echo �ش� No�� �ش��ϴ� ���� �׸��� �����ϴ�.
    goto :eof
)

set "selectedID=!id[%choice%]!"

echo ���õ� ID(!selectedID!)�� �⺻ ���� �׸����� ���� ��...
bcdedit /default !selectedID! >nul 2>&1

if %errorlevel% neq 0 (
    echo ����: bcdedit �⺻ ���� �׸� ���� ����.
    goto :eof
)

echo ���������� �����Ǿ����ϴ�.

echo.
CHOICE /T 5 /N /C yn /D n /M "5�� �� ����� �մϴ�. ����Ͻðڽ��ϱ�? (Y/N): "

if %errorlevel% equ 1 (
	echo ������� ��� �Ǿ����ϴ�.
	goto :eof
)

echo ������� �����մϴ�.
shutdown /r /t 0

goto :eof

:PrintAligned
:: %1=index, %2=description, %3=device
set "idx=  %1"
set "desc=%~2"
set "dev=%~3"

:: �е�
set "pad=                              "  :: 30ĭ
set "idx=!idx:~-2!"                     :: ������ ���� (3�ڸ�)
set "desc=!desc!!pad!"
set "desc=!desc:~0,30!"                :: description: �ִ� 30��

echo  !idx!.   !desc! !dev!
goto :eof

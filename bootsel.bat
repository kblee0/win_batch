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
        set "description="
        set "device="
    ) else if /i "!key!"=="description" (
        set "description=!value!"
    ) else if /i "!key!"=="device" (
        set "device=!value!"
    )

    if not "!identifier!"=="" if not "!description!" == "" if not "!device!" == "" (
        if /i not "!identifier!"=="{bootmgr}" (
            call :PrintAligned !index! "!description!" "!device!"
			set "id[!index!]=!identifier!"
			set "indexchoice=!indexchoice!!index!"
            set /a index+=1
        )
        set "identifier="
        set "description="
        set "device="
    )
)

echo.
choice /n /c !indexchoice!0 /M "�⺻ ���� �׸� (0: ���): "

set choice=%errorlevel%

if not defined id[%choice%] (
    goto :eof
)

set "selectedID=!id[%choice%]!"

echo.
choice /n /c 120 /M "1. �⺻������ �����, 2. �ӽú���, 0, ��� ? "
echo.

if %errorlevel% equ 1 (
	echo ���õ� ID^(%selectedID%^)�� �⺻ ���� �׸����� �����մϴ�...
	bcdedit /default %selectedID% >nul 2>&1
	if !errorlevel! neq 0 (
		echo ����: bcdedit �⺻ ���� �׸� ���� ����.
		EXIT /B
	)
	echo ������� �����մϴ�.
	shutdown /r /t 0

	EXIT /B
)

if %errorlevel% equ 2 (
	echo ���õ� ID^(%selectedID%^)�� ���� ���� �������� �����մϴ�...
	echo bcdedit /bootsequence %selectedID% >nul 2>&1
	if !errorlevel! neq 0 (
		echo ����: bcdedit ���� ���� ������ ���� ����.
		EXIT /B
	)
	echo ������� �����մϴ�.
	shutdown /r /t 0

	EXIT /B
)

EXIT /B

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

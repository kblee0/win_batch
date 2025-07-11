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
set "ppath="
set /a index=1

:main
cls
echo ================================
echo  No    Description
echo ================================

for /f "tokens=1,* delims= " %%A in ('bcdedit /enum firmware') do (
    set "key=%%A"
    set "value=%%B"

    if /i "!key!"=="identifier" (
        set "identifier=!value!"
        set "description="
        set "ppath="
    ) else if /i "!key!"=="path" (
        set "ppath=!value!"
    ) else if /i "!key!"=="description" (
        set "description=!value!"
    )

    if not "!identifier!"=="" if not "!description!" == "" if not "!ppath!" == "" (
        if /i not "!identifier!"=="{bootmgr}" (
            call :PrintAligned !index! "!description!"
			set "id[!index!]=!identifier!"
            set /a index+=1
        )
        set "identifier="
        set "description="
        set "ppath="
    )
)

set choice=
echo.
set /p choice="�⺻ ���� �׸� (0: ���): "

if not defined id[%choice%] (
    goto :eof
)

set "selectedID=!id[%choice%]!"

set choice=
echo.
set /p choice="1. �⺻���� �� �����, 0. ��� : "
echo.

if %choice% equ 1 (
	echo ���õ� ID^(%selectedID%^)�� �⺻ ���� �׸����� �����մϴ�...
	bcdedit /set {fwbootmgr} default %selectedID% >nul 2>&1
	if !errorlevel! neq 0 (
		echo ����: bcdedit �⺻ ���� �׸� ���� ����.
		EXIT /B
	)
	echo ������� �����մϴ�.
	shutdown /r /t 0

	EXIT /B
)

EXIT /B

:PrintAligned
:: %1=index, %2=description
set "idx=  %1"
set "desc=%~2"

:: �е�
set "pad=                              "  :: 30ĭ
set "idx=!idx:~-2!"                     :: ������ ���� (3�ڸ�)

echo  !idx!.   !desc!
goto :eof

@echo off
setlocal enabledelayedexpansion

pushd "%~dp0secure"

for %%F in (*) do (
    set "VAR_NAME=%%F"
    set "VAR_VALUE="

    REM 첫 줄만 읽고 바로 종료하기 위해 내부 flag 사용
    set "LINE_READ="
    for /f "usebackq delims=" %%A in ("%%F") do (
        if not defined LINE_READ (
            set "VAR_VALUE=%%A"
            set "LINE_READ=1"
        )
    )

    setx "!VAR_NAME!" "!VAR_VALUE!"
    echo set "!VAR_NAME!=!VAR_VALUE!"
)
popd
pause

@echo off
setlocal enabledelayedexpansion

pushd "%~dp0secure"

for %%F in (*) do (
    set "VAR_NAME=%%F"
    set "VAR_VALUE="

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

@echo off
setlocal ENABLEEXTENSIONS

set /P "BASE=삭제할 루트 디렉토리 경로 입력: "

set "TBASE="%BASE%\Program Files" "%BASE%\Program Files (x86)" %BASE%\ProgramData %BASE%\Users %BASE%\Windows"

echo [INFO] 시작 디렉토리: %BASE%

for %%D in (%TBASE%) do (
    echo === 삭제 경로: %%~D ===
    rd /s /q "%%~D"
)

echo [DONE] 모든 디렉토리 삭제 완료.
endlocal
pause
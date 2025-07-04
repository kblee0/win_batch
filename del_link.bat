@echo off
setlocal ENABLEEXTENSIONS

set /P "TARGET_DIR=삭제할 루트 디렉토리 경로 입력: "

echo [INFO] 시작 디렉토리: %TARGET_DIR%
echo [INFO] 심볼릭 링크 및 정션 디렉토리 삭제 시작...

:: FOR /F 루프로 디렉토리 목록에서 symlink/junction 타입만 걸러서 삭제
for /f "delims=" %%A in ('dir "%TARGET_DIR%" /AL /S /B') do (
    echo [DELETE] %%A
    rmdir "%%A"
)

echo [DONE] 모든 링크 삭제 완료.
endlocal
pause
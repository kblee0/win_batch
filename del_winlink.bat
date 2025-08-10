@echo off
setlocal ENABLEEXTENSIONS

set /P "BASE=삭제할 루트 디렉토리 경로 입력: "

set "TBASE="%BASE%\Program Files" "%BASE%\Program Files (x86)" %BASE%\ProgramData %BASE%\Users %BASE%\Windows"
set "TDIR="%BASE%\Documents and Settings""

echo [INFO] 시작 디렉토리: %BASE%
echo [INFO] 심볼릭 링크 및 정션 디렉토리 삭제 시작...


for %%D in (%TDIR%) do (
    echo 삭제: "%%~D"
    echo rd "%%~D"
    if exist "%%~D" (
        echo Failed to delete: "%%~D"
    ) else (
        echo Deleted: "%%~D"
    )        
)

for %%D in (%TBASE%) do (
    echo === 검색 경로: %%~D ===
    for /f "delims=" %%P in ('dir /ALD /S /B "%%~D" 2^>nul') do (
        echo 삭제: "%%P"
        echo rd "%%P"
        if exist "%%P" (
            echo Failed to delete: "%%P"
        ) else (
            echo Deleted: "%%P"
        )        
    )
)

echo [DONE] 모든 링크 삭제 완료.
endlocal
pause
@echo off
setlocal ENABLEEXTENSIONS

set /P "BASE=������ ��Ʈ ���丮 ��� �Է�: "

set "TBASE="%BASE%\Program Files" "%BASE%\Program Files (x86)" %BASE%\ProgramData %BASE%\Users %BASE%\Windows"
set "TDIR="%BASE%\Documents and Settings""

echo [INFO] ���� ���丮: %BASE%
echo [INFO] �ɺ��� ��ũ �� ���� ���丮 ���� ����...


for %%D in (%TDIR%) do (
    echo ����: "%%~D"
    echo rd "%%~D"
    if exist "%%~D" (
        echo Failed to delete: "%%~D"
    ) else (
        echo Deleted: "%%~D"
    )        
)

for %%D in (%TBASE%) do (
    echo === �˻� ���: %%~D ===
    for /f "delims=" %%P in ('dir /ALD /S /B "%%~D" 2^>nul') do (
        echo ����: "%%P"
        echo rd "%%P"
        if exist "%%P" (
            echo Failed to delete: "%%P"
        ) else (
            echo Deleted: "%%P"
        )        
    )
)

echo [DONE] ��� ��ũ ���� �Ϸ�.
endlocal
pause
@echo off
setlocal ENABLEEXTENSIONS

set /P "TARGET_DIR=������ ��Ʈ ���丮 ��� �Է�: "

echo [INFO] ���� ���丮: %TARGET_DIR%
echo [INFO] �ɺ��� ��ũ �� ���� ���丮 ���� ����...

:: FOR /F ������ ���丮 ��Ͽ��� symlink/junction Ÿ�Ը� �ɷ��� ����
for /f "delims=" %%A in ('dir "%TARGET_DIR%" /AL /S /B') do (
    echo [DELETE] %%A
    rmdir "%%A"
)

echo [DONE] ��� ��ũ ���� �Ϸ�.
endlocal
pause
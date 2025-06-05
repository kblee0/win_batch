@echo off
setlocal enabledelayedexpansion

set SED=C:\home\dev\git\usr\bin\sed.exe

:: ������ ���丮�� ���� ��� (���� ��ġ ������ ����Ǵ� ��ġ�� �������� ��)
set "baseDir=C:\home\dev\vscode\data\extensions"
set "targetFile=dist\gitlens.js"

echo %baseDir% ���丮 ���� ���� ���� ������ �˻��մϴ�...

:: extensions ���丮 ���� ��� ���丮�� ��ȸ (���� ���� ã��)
for /d %%v in ("%baseDir%\eamodio.gitlens-*") do (
    set "versionDir=%%v"
    set "fullPath=!versionDir!\!targetFile!"
    
    echo.
    echo ��� ���� Ȯ��: !fullPath!

    :: ������ �����ϴ��� Ȯ��
    if exist "!fullPath!" (
        echo !fullPath! ���Ͽ��� ���ڿ��� �����մϴ�...

        :: �ӽ� ���� ��� ����
        set "tempFile=!fullPath!.tmp"

        :: �ӽ� ������ �̹� �����ϸ� ����
        if exist "!tempFile!" del "!tempFile!"

        :: ���� ������ �о� ���� �� �ӽ� ���Ͽ� ����
        %SED% -i -E "s/qn\.(Community|CommunityWithAccount|Pro)/qn.Enterprise/g" "!fullPath!"

        echo ���� �Ϸ�
    ) else (
        echo !fullPath! ������ ã�� �� �����ϴ�. �ǳʍ��ϴ�.
    )
)

echo.
echo Gitlens ��ġ�� �Ϸ� �Ǿ����ϴ�.
echo.
endlocal
pause
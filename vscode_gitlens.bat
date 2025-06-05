@echo off
setlocal enabledelayedexpansion

set SED=C:\home\dev\git\usr\bin\sed.exe

:: 변경할 디렉토리의 상위 경로 (현재 배치 파일이 실행되는 위치를 기준으로 함)
set "baseDir=C:\home\dev\vscode\data\extensions"
set "targetFile=dist\gitlens.js"

echo %baseDir% 디렉토리 내의 가변 버전 폴더를 검색합니다...

:: extensions 디렉토리 내의 모든 디렉토리를 순회 (버전 폴더 찾기)
for /d %%v in ("%baseDir%\eamodio.gitlens-*") do (
    set "versionDir=%%v"
    set "fullPath=!versionDir!\!targetFile!"
    
    echo.
    echo 대상 파일 확인: !fullPath!

    :: 파일이 존재하는지 확인
    if exist "!fullPath!" (
        echo !fullPath! 파일에서 문자열을 변경합니다...

        :: 임시 파일 경로 설정
        set "tempFile=!fullPath!.tmp"

        :: 임시 파일이 이미 존재하면 삭제
        if exist "!tempFile!" del "!tempFile!"

        :: 파일 내용을 읽어 변경 후 임시 파일에 쓰기
        %SED% -i -E "s/qn\.(Community|CommunityWithAccount|Pro)/qn.Enterprise/g" "!fullPath!"

        echo 변경 완료
    ) else (
        echo !fullPath! 파일을 찾을 수 없습니다. 건너뜝니다.
    )
)

echo.
echo Gitlens 패치가 완료 되었습니다.
echo.
endlocal
pause
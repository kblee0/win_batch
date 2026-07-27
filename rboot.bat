@echo off
setlocal

:: 초기 변수 설정
set "MODE="
set "TARGET="

:: 매개변수 파싱 (최대 2개 매개변수 검사)

:parse_args

if [%~1]==[] goto validate

if /i "%~1"=="/r" set "MODE=/r" & shift & goto parse_args
if /i "%~1"=="/p" set "MODE=/p" & shift & goto parse_args
if /i "%~1"=="/o" set "MODE=/o" & shift & goto parse_args

if /i "%~1"=="kt"  set "TARGET=kt"  & shift & goto parse_args
if /i "%~1"=="rnb" set "TARGET=rnb" & shift & goto parse_args

:: 유효하지 않은 인자 처리

echo [오류] 알 수 없는 매개변수입니다: %~1
goto usage

:validate

:: 타겟 필수 체크
if "%TARGET%"=="" (
    echo [오류] 부팅 대상^(kt 또는 rnb^)을 지정해야 합니다.
    goto usage
)

:: 타겟별 GUID 및 백업 여부 설정
if /i "%TARGET%"=="kt" (
    set "GUID={bb0223c0-5d5d-11f0-afe1-806e6f6e6963}"
	echo "DRM 대상 문서 백업중..."
	robocopy C:\home C:\doc\home\bak *.doc? *.xls? *.ppt? *.pdf *.rtf *.csv /S /XO /R:1 /W:1 /XD doc $RECYCLE.BIN /NJH /NJS /NDL /NP
)
if /i "%TARGET%"=="rnb" set "GUID={bb0223c1-5d5d-11f0-afe1-806e6f6e6963}"

:: BCD 설정 및 시스템 종료/재부팅 분기
if /i "%MODE%"=="/o" (
    echo 1회성 재부팅 설정 중... [%TARGET%]
    gsudo bcdedit.exe /bootsequence %GUID%
    if errorlevel 1 goto error_exit
    shutdown /r /t 0
) else (
    echo 기본 부팅 항목 변경 중... [%TARGET%]
    gsudo bcdedit.exe /set {fwbootmgr} default %GUID%
    if errorlevel 1 goto error_exit

    if /i "%MODE%"=="/r" (
        shutdown /r /t 0
    ) else if /i "%MODE%"=="/p" (
        shutdown /s /t 0
    )
)

goto :eof

:usage
echo.
echo 사용법: rboot.bat [/r ^| /p ^| /o] [kt ^| rnb]
echo   /r : 설정 후 즉시 재부팅
echo   /p : 설정 후 즉시 전원 종료
echo   /o : 1회성(Next Boot) 재부팅 설정 후 즉시 재부팅
echo   (옵션 미입력 시 BCD 기본값만 변경하고 종료하지 않음)
echo.
exit /b 1

:error_exit
echo [오류] BCD 수정에 실패했습니다. (gsudo 권한 확인 필요)
exit /b 1

@echo off
setlocal
set DEVHOME=C:\home\dev

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 관리자 권한이 필요합니다.
    exit /b
)
cls

:: Get system path
for /f "tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul ^| findstr /i /c:"REG_EXPAND_SZ" /c:"REG_SZ"') do SET "SYS_PATH=%%B"

:: -------------------------------------------
:: Jetbrain
:: -------------------------------------------
setx /M IDEA_PROPERTIES     %DEVHOME%\.config\IntelliJ.properties
setx /M PYCHARM_PROPERTIES  %DEVHOME%\.config\PyCharm.properties
setx /M DATAGRIP_PROPERTIES %DEVHOME%\.config\DataGrip.properties
setx /M WEBIDE_PROPERTIES   %DEVHOME%\.config\WebStorm.properties

:: -------------------------------------------
:: JAVA
:: -------------------------------------------
setx /M JAVA_HOME %DEVHOME%\Java\jdk-21.0.11+10

set SYS_PATH=%SYS_PATH%;%%JAVA_HOME%%\bin

:: -------------------------------------------
:: Maven : M2_HOME 호환설정
:: -------------------------------------------
setx /M MAVEN_HOME %DEVHOME%\apache-maven-3.9.16
setx /M M2_HOME %%MAVEN_HOME%%
setx /M MAVEN_OPTS -Dmaven.repo.local=%DEVHOME%\.data\maven

set SYS_PATH=%SYS_PATH%;%%MAVEN_HOME%%\bin

:: -------------------------------------------
:: Gradle
:: -------------------------------------------
setx /M GRADLE_HOME %DEVHOME%\gradle-9.6.1
setx /M GRADLE_USER_HOME %DEVHOME%\.data\gradle

set SYS_PATH=%SYS_PATH%;%%GRADLE_HOME%%\bin

:: -------------------------------------------
:: Node
:: -------------------------------------------
setx /M NVM_HOME %DEVHOME%\nvm
setx /M NPM_CONFIG_USERCONFIG %%NVM_HOME%%\.npmrc

SET SYS_PATH=%SYS_PATH%;%%NVM_HOME%%
SET SYS_PATH=%SYS_PATH%;node_modules\.bin
SET SYS_PATH=%SYS_PATH%;%%NVM_HOME%%\nodejs

:: -------------------------------------------
:: Git
:: -------------------------------------------
setx /M GIT_CONFIG_GLOBAL %DEVHOME%\.config\git\.gitconfig

set SYS_PATH=%SYS_PATH%;%DEVHOME%\git\bin

:: -------------------------------------------
:: Python : PYENV 호환설정
:: -------------------------------------------
:: git clone https://github.com/pyenv-win/pyenv-win.git %DEVHOME%\pyenv
setx /M PYENV_ROOT %DEVHOME%\pyenv\pyenv-win
setx /M PYENV %%PYENV_ROOT%%
setx /M PIP_CONFIG_FILE %DEVHOME%\.config\pip\pip.ini

set SYS_PATH=%SYS_PATH%;%%PYENV_ROOT%%\bin
set SYS_PATH=%SYS_PATH%;%%PYENV_ROOT%%\shims

:: -------------------------------------------
:: SVN
:: -------------------------------------------
set SYS_PATH=%SYS_PATH%;%DEVHOME%\svn\bin

:: -------------------------------------------
:: miniconda
:: -------------------------------------------
:: Invoke-WebRequest -Uri "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"  -OutFile "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe"
:: "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe" /InstallationType=JustMe /AddToPath=0 /S /RegisterPython=0 /NoRegistry=1 /NoScripts=1 /NoShortcuts=1 /D=%DEVHOME%\miniconda

:: set SYS_PATH=%SYS_PATH%;%DEVHOME%\miniconda\condabin
:: set SYS_PATH=%SYS_PATH%;%DEVHOME%\miniconda\Scripts

:: conda config --system --append envs_dirs %DEVHOME%\.data\miniconda
:: conda create -n venv python=3.13.3

:: --------- Global Path --------
:: Path 중복 제거 후 설정
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$path = $env:SYS_PATH;" ^
    "if (-not $path -or $path.Trim() -eq '') {" ^
    "    Write-Error 'SYS_PATH 환경 변수가 설정되지 않았거나 값이 비어 있습니다. (작업 중단)';" ^
    "    exit 1;" ^
    "};" ^
    "$uniquePath = ($path -split ';' | Where-Object { $_.Trim() -ne '' } | Select-Object -Unique) -join ';';" ^
    "$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment';" ^
    "Set-ItemProperty -Path $regPath -Name 'Path' -Value $uniquePath -Type ExpandString;" ^
    "Write-Output ('[M] PATH=' + $uniquePath);"

:: -------------------------------------------
:: Secure environment variables
:: -------------------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$dir = Join-Path '%~dp0' 'secure';" ^
    "if (-not (Test-Path $dir)) { Write-Error "'$dir' 디렉토리를 찾을 수 없습니다."; exit 1 };" ^
    "Get-ChildItem -Path $dir -File | ForEach-Object {" ^
    "    $name = $_.Name;" ^
    "    $val = (Get-Content -Path $_.FullName -Raw).Trim();" ^
    "    if ($val) {" ^
    "        [Environment]::SetEnvironmentVariable($name, $val, 'User');" ^
    "        Write-Output \"[U] $name=$val\";" ^
    "    }" ^
    "}"

:: -------------------------------------------
:: User setting
:: -------------------------------------------
echo -------------------------------------------
echo type below command unber user command env
echo -------------------------------------------

echo git config --global pull.rebase true
echo git config --global fetch.prune true
echo git config --global rebase.autoStash true
echo.
echo git config --global push.default simple
echo git config --global push.autoSetupRemote true
echo git config --global init.defaultBranch main
echo.
echo git config --global core.autocrlf false
echo git config --global core.filemode false
echo git config --global merge.conflictStyle zdiff3
echo.
echo git config --global credential.helper "store --file=C:/home/dev/.config/git/.git-credentials"
echo.
echo git config --global --unset-all safe.directory
echo git config --global safe.directory *
echo.
echo git config --global user.name "kblee0"
echo git config --global user.email "kblee0@gmail.com"

endlocal

pause

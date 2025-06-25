@echo off

:check_admin
net session >nul 2>&1
if %errorlevel% neq 0 (
	if exist %SystemRoot%\system32\sudo.exe (
		sudo --inline %~f0
	) else (
		Echo You must have administrator rights to continue ...
	)
	Exit /B																									
)

:: %SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\;%SYSTEMROOT%\System32\OpenSSH\

for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do (
  SET SYS_PATH=%%B
)

:: -------------------------------------------
:: Jetbrain
:: -------------------------------------------

setx /M IDEA_PROPERTIES     c:\home\dev\.config\IntelliJ.properties
setx /M PYCHARM_PROPERTIES  c:\home\dev\.config\PyCharm.properties
setx /M DATAGRIP_PROPERTIES c:\home\dev\.config\DataGrip.properties
setx /M WEBIDE_PROPERTIES   c:\home\dev\.config\WebStorm.properties

:: -------------------------------------------
:: JAVA
:: -------------------------------------------

setx /M JAVA_HOME C:\home\dev\Java\jdk-21.0.4+7
set SYS_PATH=%SYS_PATH%;%%JAVA_HOME%%\bin

:: -------------------------------------------
:: Maven
:: -------------------------------------------

setx /M M2_HOME C:\home\dev\apache-maven-3.9.9

set SYS_PATH=%SYS_PATH%;%%M2_HOME%%\bin


:: -------------------------------------------
:: Gradle
:: -------------------------------------------

setx /M GRADLE_HOME C:\home\dev\gradle-8.13
setx /M GRADLE_USER_HOME C:\home\dev\.data\gradle\repo

set SYS_PATH=%SYS_PATH%;%%GRADLE_HOME%%\bin

:: -------------------------------------------
:: Node
:: -------------------------------------------

setx /M NVM_HOME c:\home\dev\nvm
set SYS_PATH=%SYS_PATH%;%%NVM_HOME%%;%%NVM_HOME%%\nodejs\.npm\global;%%NVM_HOME%%\nodejs

:: -------------------------------------------
:: Git
:: -------------------------------------------
set SYS_PATH=%SYS_PATH%;C:\home\dev\git\bin

:: -------------------------------------------
:: SVN
:: -------------------------------------------
set SYS_PATH=%SYS_PATH%;C:\home\dev\svn\bin


:: -------------------------------------------
:: miniconda
:: -------------------------------------------
:: Invoke-WebRequest -Uri "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"  -OutFile "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe"
:: "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe" /InstallationType=JustMe /AddToPath=0 /S /RegisterPython=0 /NoRegistry=1 /NoScripts=1 /NoShortcuts=1 /D=C:\home\dev\miniconda

set SYS_PATH=%SYS_PATH%;C:\home\dev\miniconda\condabin;C:\home\dev\miniconda\Scripts
set PATH=%PATH%;C:\home\dev\miniconda\condabin;C:\home\dev\miniconda\Scripts

:: conda config --system --append envs_dirs c:\home\dev\.data\miniconda
:: conda create -n venv python=3.13.3

:: --------- Global Path --------
setx /M PATH "%SYS_PATH%"

:: -------------------------------------------
:: Secure environment variables
:: -------------------------------------------
IF EXIST "%~dp0secureenv.bat" CALL "%~dp0secureenv.bat"

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

:: -------------------------------------------
:: User setting
:: -------------------------------------------
echo -------------------------------------------
echo type below command unber user command env
echo -------------------------------------------

git config --global user.name "kblee0"
git config --global user.email kblee0@gmail.com
git config credential.helper store
npm config -g set prefix C:\home\dev\nvm\nodejs\.npm\global
npm config -g set cache C:\home\dev\nvm\nodejs\.npm\cache
echo python -m venv C:\home\dev\.data\venv313
echo conda config --system --append envs_dirs c:\home\dev\.data\miniconda

pause
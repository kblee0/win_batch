@echo off

setlocal

::-------------------------------------------------------------------------
:: Functions
::-------------------------------------------------------------------------
goto main

:sys_path_append
set "TARGET_PATH=%~1"
set "FOUND=0"
for %%D in ("%SYS_PATH:;=" "%") do if /I "%%~D"=="%TARGET_PATH%" set "FOUND=1"
if "%FOUND%"=="0" set "SYS_PATH=%SYS_PATH%;%TARGET_PATH%"
goto :eof
::-------------------------------------------------------------------------

:main

:: Check if running as administrator
Reg.exe query "HKU\S-1-5-19\Environment"
If Not %ERRORLEVEL% EQU 0 (
	if exist %SystemRoot%\system32\sudo.exe (
		sudo --inline %~f0
	) else (
		Echo You must have administrator rights to continue ...
	)
	Exit /B
)
Cls

:: Get system path
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do SET SYS_PATH=%%B

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

setx /M JAVA_HOME C:\home\dev\Java\jdk-21.0.11+10
call :sys_path_append %%%%JAVA_HOME%%%%\bin

:: -------------------------------------------
:: Maven
:: -------------------------------------------
setx /M MAVEN_HOME=C:\home\dev\apache-maven-3.9.16
setx /M M2_HOME %MAVEN_HOME%
setx /M MAVEN_OPTS -Dmaven.repo.local=C:\home\dev\.data\maven
call :sys_path_append %%%%M2_HOME%%%%\bin

:: -------------------------------------------
:: Gradle
:: -------------------------------------------

setx /M GRADLE_HOME C:\home\dev\gradle-9.6.1
setx /M GRADLE_USER_HOME C:\home\dev\.data\gradle

call :sys_path_append %%%%GRADLE_HOME%%%%\bin

:: -------------------------------------------
:: Node
:: -------------------------------------------

setx /M NVM_HOME c:\home\dev\nvm
setx /M NPM_CONFIG_USERCONFIG C:\home\dev\nvm\.npmrc
call :sys_path_append %%%%NVM_HOME%%%%
call :sys_path_append node_modules\.bin
call :sys_path_append %%%%NVM_HOME%%%%\nodejs

:: -------------------------------------------
:: Git
:: -------------------------------------------
setx /M GIT_CONFIG_GLOBAL C:\home\dev\.config\git\.gitconfig
call :sys_path_append C:\home\dev\git\bin

:: -------------------------------------------
:: Python
:: -------------------------------------------
:: git clone https://github.com/pyenv-win/pyenv-win.git c:\home\dev\pyenv
setx /M PYENV_ROOT C:\home\dev\pyenv\pyenv-win
setx /M PYENV C:\home\dev\pyenv\pyenv-win
:: set PATH=%PYENV%\bin;%PYENV%\shims;%PATH%
call :sys_path_append %%%%PYENV%%%%\bin
call :sys_path_append %%%%PYENV%%%%\shims

:: -------------------------------------------
:: SVN
:: -------------------------------------------
call :sys_path_append C:\home\dev\svn\bin


:: -------------------------------------------
:: miniconda
:: -------------------------------------------
:: Invoke-WebRequest -Uri "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"  -OutFile "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe"
:: "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe" /InstallationType=JustMe /AddToPath=0 /S /RegisterPython=0 /NoRegistry=1 /NoScripts=1 /NoShortcuts=1 /D=C:\home\dev\miniconda

call :sys_path_append C:\home\dev\miniconda\condabin
call :sys_path_append C:\home\dev\miniconda\Scripts

:: conda config --system --append envs_dirs c:\home\dev\.data\miniconda
:: conda create -n venv python=3.13.3

:: --------- Global Path --------
setx /M PATH "%SYS_PATH%"

:: -------------------------------------------
:: Secure environment variables
:: -------------------------------------------
IF EXIST "%~dp0secureenv.bat" CALL "%~dp0secureenv.bat"

:: -------------------------------------------
:: User setting
:: -------------------------------------------
echo -------------------------------------------
echo type below command unber user command env
echo -------------------------------------------

echo git config --global pull.ff only
echo git config --global fetch.prune true
echo git config --global rebase.autoStash true
echo
echo git config --global push.default simple
echo git config --global push.autoSetupRemote true
echo git config --global init.defaultBranch main
echo
echo git config --global core.autocrlf false
echo git config --global core.filemode false
echo git config --global merge.conflictStyle zdiff3
echo
echo git config --global credential.helper "store --file=C:/home/dev/.config/git/.git-credentials"
echo
echo git config --global user.name "kblee0"
echo git config --global user.email "kblee0@gmail.com"

pause

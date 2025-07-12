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
net session >nul 2>&1
if %errorlevel% neq 0 (
	if exist %SystemRoot%\system32\sudo.exe (
		sudo --inline %~f0
	) else (
		Echo You must have administrator rights to continue ...
	)
	Exit /B																									
)

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

setx /M JAVA_HOME C:\home\dev\Java\jdk-21.0.4+7
call :sys_path_append %%%%JAVA_HOME%%%%\bin

:: -------------------------------------------
:: Maven
:: -------------------------------------------

setx /M M2_HOME C:\home\dev\apache-maven-3.9.9

call :sys_path_append %%%%M2_HOME%%%%\bin

:: -------------------------------------------
:: Gradle
:: -------------------------------------------

setx /M GRADLE_HOME C:\home\dev\gradle-8.13
setx /M GRADLE_USER_HOME C:\home\dev\.data\gradle\repo

call :sys_path_append %%%%GRADLE_HOME%%%%\bin

:: -------------------------------------------
:: Node
:: -------------------------------------------

setx /M NVM_HOME c:\home\dev\nvm
call :sys_path_append %%%%NVM_HOME%%%%
call :sys_path_append %%%%NVM_HOME%%%%\nodejs\.npm\global
call :sys_path_append %%%%NVM_HOME%%%%\nodejs

:: -------------------------------------------
:: Git
:: -------------------------------------------
call :sys_path_append C:\home\dev\git\bin

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

echo git config --global user.name "kblee0"
echo git config --global user.email kblee0@gmail.com
echo git config --global credential.helper manager
echo git config --global --add safe.directory c:\home\proj
echo npm config -g set prefix C:\home\dev\nvm\nodejs\.npm\global
echo npm config -g set cache C:\home\dev\nvm\nodejs\.npm\cache
echo python -m venv C:\home\dev\.data\venv313
echo conda config --system --append envs_dirs c:\home\dev\.data\miniconda

pause
@echo off

rem %SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\;%SYSTEMROOT%\System32\OpenSSH\

for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do (
  SET SYS_PATH=%%B
)

rem -------------------------------------------
rem Jetbrain
rem -------------------------------------------

setx /M IDEA_PROPERTIES     c:\home\dev\.config\IntelliJ.properties
setx /M PYCHARM_PROPERTIES  c:\home\dev\.config\PyCharm.properties
setx /M DATAGRIP_PROPERTIES c:\home\dev\.config\DataGrip.properties
setx /M WEBIDE_PROPERTIES   c:\home\dev\.config\WebStorm.properties

rem -------------------------------------------
rem JAVA
rem -------------------------------------------

setx /M JAVA_HOME C:\home\dev\Java\jdk-21.0.4+7
set SYS_PATH=%SYS_PATH%;%%JAVA_HOME%%\bin

rem -------------------------------------------
rem Maven
rem -------------------------------------------

setx /M M2_HOME C:\home\dev\apache-maven-3.9.9

set SYS_PATH=%SYS_PATH%;%%M2_HOME%%\bin


rem -------------------------------------------
rem Gradle
rem -------------------------------------------

setx /M GRADLE_HOME C:\home\dev\gradle-8.13
setx /M GRADLE_USER_HOME C:\home\dev\.data\gradle\repo

set SYS_PATH=%SYS_PATH%;%%GRADLE_HOME%%\bin

rem -------------------------------------------
rem Node
rem -------------------------------------------

setx /M NVM_HOME c:\home\dev\nvm
set SYS_PATH=%SYS_PATH%;%%NVM_HOME%%;%%NVM_HOME%%\nodejs\.npm\global;%%NVM_HOME%%\nodejs

rem -------------------------------------------
rem Python
rem -------------------------------------------

setx /M PYTHON_HOME C:\home\dev\Python
setx /M VIRTUAL_ENV C:\home\dev\pyvenv
set SYS_PATH=%SYS_PATH%;%%PYTHON_HOME%%\Scripts;%%PYTHON_HOME%%;%%VIRTUAL_ENV%%\Scripts

rem -------------------------------------------
rem Git
rem -------------------------------------------
setx /M GITHUB_TOKEN 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
set SYS_PATH=%SYS_PATH%;C:\home\dev\git\bin

rem -------------------------------------------
rem SVN
rem -------------------------------------------
set SYS_PATH=%SYS_PATH%;C:\home\dev\svn\bin


rem --------- Global Path --------
setx /M PATH "%SYS_PATH%"


rem -------------------------------------------
rem User setting
rem -------------------------------------------
echo -------------------------------------------
echo type below command unber user command env
echo -------------------------------------------

echo pyhton -m venv C:\home\dev\pyvenv
echo git config --global user.name "kblee0"
echo git config --global user.email kblee0@gmail.com
echo git config credential.helper store
echo npm config -g set prefix C:\home\dev\nvm\nodejs\.npm\global
echo npm config -g set cache C:\home\dev\nvm\nodejs\.npm\cache

pause
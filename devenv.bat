@echo off

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
:: Python
:: -------------------------------------------

setx /M PYTHON_HOME C:\home\dev\Python
setx /M VIRTUAL_ENV C:\home\dev\.data\.venv
set SYS_PATH=%SYS_PATH%;%%PYTHON_HOME%%\Scripts;%%PYTHON_HOME%%;%%VIRTUAL_ENV%%\Scripts

:: -------------------------------------------
:: Git
:: -------------------------------------------
setx /M GITHUB_TOKEN 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
set SYS_PATH=%SYS_PATH%;C:\home\dev\git\bin

:: -------------------------------------------
:: SVN
:: -------------------------------------------
set SYS_PATH=%SYS_PATH%;C:\home\dev\svn\bin


:: --------- Global Path --------
setx /M PATH "%SYS_PATH%"


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
echo pyhton -m venv C:\home\dev\.data\.venv

pause
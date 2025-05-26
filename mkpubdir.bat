@echo off
SET DIR=%1

mkdir %DIR%
IF %ERRORLEVEL% NEQ 0 EXIT /B
:: 기존 상속 제거하고 권한 초기화
icacls %DIR% /inheritance:r
:: Everyone에게 모든 권한 부여
icacls %DIR% /grant Everyone:(OI)(CI)F
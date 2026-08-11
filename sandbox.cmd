@echo off

reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" ^
    /v VerifiedAndReputablePolicyState ^
    /t REG_DWORD ^
    /d 0 ^
    /f

CiTool.exe -r
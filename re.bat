@echo off

:: Diskpart
:: Recovery partition setup
set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
gpt attributes=0x8000000000000001

:: WinRE.wim extraction
dism /get-imageinfo /imagefile:D:\sources\install.wim
md C:\mount
dism /mount-image /imagefile:D:\sources\install.wim /index:6 /mountdir:C:\mount /readonly
md C:\Temp
copy C:\mount\Windows\System32\Recovery\WinRE.wim C:\Temp\
dism /unmount-image /mountdir:C:\mount /discard

:: Recovery image setup
mkdir R:\Recovery\WindowsRE
xcopy C:\Temp\WinRE.wim R:\Recovery\WindowsRE\
reagentc /setreimage /path R:\Recovery\WindowsRE /target C:\Windows
reagentc /enable
reagentc /info

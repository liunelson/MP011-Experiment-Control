@echo off
If EXIST "%HomeDrive%\Program Files (x86)" (
    cd 64 Bit Installer
    setup.exe
) ELSE (
    cd 32 Bit Installer
    setup.exe
)

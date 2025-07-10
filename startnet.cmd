@echo off
wpeinit
echo Running hardware stress test...

:: Log folder
set LOGDIR=X:\logs
mkdir %LOGDIR%

:: CPU Stress (Giả định có stress-ng.exe)
X:\Tools\stress-ng.exe --cpu 4 --timeout 60s > %LOGDIR%\cpu.txt

:: RAM Test (giả định bạn có tool ramtest.exe)
X:\Tools\ramtest.exe > %LOGDIR%\ram.txt

:: Disk Test
X:\Tools\diskcheck.exe /all /log %LOGDIR%\disk.txt

:: Network test
ping 8.8.8.8 -n 5 > %LOGDIR%\ping.txt

echo Done. Logs saved to %LOGDIR%
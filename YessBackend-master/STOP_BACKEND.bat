@echo off
echo ========================================
echo Остановка Backend процессов
echo ========================================
echo.

echo Поиск процессов dotnet, связанных с YessBackend.Api...
for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq dotnet.exe" /FO LIST ^| findstr /I "PID"') do (
    set PID=%%a
    set PID=!PID: =!
    wmic process where "ProcessId=!PID!" get CommandLine 2>nul | findstr /I "YessBackend.Api" >nul
    if !ERRORLEVEL! EQU 0 (
        echo Обнаружен процесс backend с PID: !PID!
        echo Остановка процесса...
        taskkill /PID !PID! /F
        if !ERRORLEVEL! EQU 0 (
            echo Процесс !PID! успешно остановлен.
        ) else (
            echo Не удалось остановить процесс !PID!
        )
    )
)

echo.
echo Готово!
timeout /t 2 /nobreak >nul


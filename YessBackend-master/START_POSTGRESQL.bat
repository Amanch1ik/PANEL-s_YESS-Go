@echo off
echo ========================================
echo Запуск PostgreSQL через Docker
echo ========================================
echo.

cd /d "%~dp0"

echo Проверка Docker...
docker --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: Docker не установлен или не запущен!
    echo Установите Docker Desktop: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo.
echo Запуск PostgreSQL контейнера...
docker-compose up -d postgres

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo PostgreSQL запущен!
    echo ========================================
    echo.
    echo Параметры подключения:
    echo   Host: localhost
    echo   Port: 5432
    echo   Database: yess_db
    echo   Username: yess_user
    echo   Password: secure_password
    echo.
    echo ВАЖНО: Обновите connection string в appsettings.json:
    echo   "Password=secure_password"
    echo.
    echo Ожидание готовности PostgreSQL (10 секунд)...
    timeout /t 10 /nobreak >nul
    echo.
    echo PostgreSQL готов к использованию!
    echo.
) else (
    echo.
    echo ========================================
    echo ОШИБКА при запуске PostgreSQL!
    echo ========================================
    echo.
)

pause


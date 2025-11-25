@echo off
echo ========================================
echo Настройка PostgreSQL для Yess Backend
echo ========================================
echo.

echo Этот скрипт поможет настроить PostgreSQL для работы с backend.
echo.
echo ВАЖНО: Убедитесь, что PostgreSQL установлен и запущен!
echo.

set /p CREATE_DB="Создать базу данных и пользователя? (y/n): "
if /i "%CREATE_DB%"=="y" (
    echo.
    echo Подключение к PostgreSQL как суперпользователь...
    echo Введите пароль пользователя postgres (обычно пустой или тот, что вы установили):
    echo.
    
    psql -U postgres -c "CREATE USER yess_user WITH PASSWORD 'password';" 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo Пользователь yess_user создан.
    ) else (
        echo Пользователь yess_user уже существует или ошибка создания.
    )
    
    psql -U postgres -c "CREATE DATABASE yess_db OWNER yess_user;" 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo База данных yess_db создана.
    ) else (
        echo База данных yess_db уже существует или ошибка создания.
    )
    
    psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE yess_db TO yess_user;" 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo Права предоставлены пользователю yess_user.
    )
    
    echo.
    echo ========================================
    echo Настройка завершена!
    echo ========================================
    echo.
    echo Теперь можно запустить backend:
    echo   dotnet run --project YessBackend.Api\YessBackend.Api.csproj
    echo.
    echo Миграции применятся автоматически при старте.
    echo.
) else (
    echo.
    echo Пропущено создание базы данных.
    echo Убедитесь, что:
    echo   1. PostgreSQL запущен
    echo   2. Пользователь yess_user существует с паролем 'password'
    echo   3. База данных yess_db существует
    echo.
)

pause


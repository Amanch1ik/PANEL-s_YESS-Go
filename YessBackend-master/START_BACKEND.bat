@echo off
echo ========================================
echo Запуск Yess Backend API
echo ========================================
echo.

cd /d "%~dp0"

echo Проверка .NET SDK...
dotnet --version
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: .NET SDK не найден!
    pause
    exit /b 1
)

echo.
echo Сборка проекта...
dotnet build YessBackend.Api/YessBackend.Api.csproj
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: Сборка не удалась!
    pause
    exit /b 1
)

echo.
echo Запуск API...
echo Backend будет доступен на: http://localhost:8000
echo Swagger UI: http://localhost:8000/docs
echo.
dotnet run --project YessBackend.Api/YessBackend.Api.csproj

pause

# Скрипт для запуска админ-панели
# Использование: .\start_admin.ps1

Write-Host "👨‍💼 Запуск Admin Panel..." -ForegroundColor Magenta

$adminPanelPath = "panels-ts-v2\admin-panel"

if (-not (Test-Path $adminPanelPath)) {
    Write-Host "✗ Путь к админ-панели не найден: $adminPanelPath" -ForegroundColor Red
    exit 1
}

Set-Location $adminPanelPath

# Проверка node_modules
if (-not (Test-Path "node_modules")) {
    Write-Host "Установка зависимостей..." -ForegroundColor Yellow
    npm install
}

# Запуск
Write-Host ""
Write-Host "🚀 Запуск на http://localhost:3003" -ForegroundColor Green
Write-Host ""
Write-Host "Нажмите Ctrl+C для остановки" -ForegroundColor Yellow
Write-Host ""

npm run dev


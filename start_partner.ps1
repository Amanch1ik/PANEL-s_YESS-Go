# Скрипт для запуска партнер-панели
# Использование: .\start_partner.ps1

Write-Host "🤝 Запуск Partner Panel..." -ForegroundColor Cyan

$partnerPanelPath = "panels-ts-v2\partner-panel"

if (-not (Test-Path $partnerPanelPath)) {
    Write-Host "✗ Путь к партнер-панели не найден: $partnerPanelPath" -ForegroundColor Red
    exit 1
}

Set-Location $partnerPanelPath

# Проверка node_modules
if (-not (Test-Path "node_modules")) {
    Write-Host "Установка зависимостей..." -ForegroundColor Yellow
    npm install
}

# Запуск
Write-Host ""
Write-Host "🚀 Запуск на http://localhost:3004" -ForegroundColor Green
Write-Host ""
Write-Host "Нажмите Ctrl+C для остановки" -ForegroundColor Yellow
Write-Host ""

npm run dev


# Скрипт для установки Node.js и запуска панелей
# Использование: .\SETUP_PANELS.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Настройка панелей Yess Backend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Проверка Node.js
Write-Host "Проверка Node.js..." -ForegroundColor Yellow
$nodeInstalled = $false
try {
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        Write-Host "✓ Node.js установлен: $nodeVersion" -ForegroundColor Green
        $nodeInstalled = $true
    }
} catch {
    $nodeInstalled = $false
}

if (-not $nodeInstalled) {
    Write-Host "✗ Node.js не найден!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Для установки Node.js:" -ForegroundColor Yellow
    Write-Host "1. Откройте браузер и перейдите на: https://nodejs.org/" -ForegroundColor White
    Write-Host "2. Скачайте LTS версию (рекомендуется)" -ForegroundColor White
    Write-Host "3. Установите с настройками по умолчанию" -ForegroundColor White
    Write-Host "4. ПЕРЕЗАПУСТИТЕ PowerShell" -ForegroundColor Yellow
    Write-Host "5. Запустите этот скрипт снова" -ForegroundColor White
    Write-Host ""
    Write-Host "Или попробуйте установить через:" -ForegroundColor Yellow
    Write-Host "  - Microsoft Store (найдите 'Node.js')" -ForegroundColor White
    Write-Host "  - Chocolatey: choco install nodejs-lts" -ForegroundColor White
    Write-Host ""
    
    # Попытка открыть страницу загрузки
    $response = Read-Host "Открыть страницу загрузки Node.js в браузере? (Y/N)"
    if ($response -eq 'Y' -or $response -eq 'y') {
        Start-Process "https://nodejs.org/"
    }
    
    exit 1
}

# Проверка npm
Write-Host "Проверка npm..." -ForegroundColor Yellow
try {
    $npmVersion = npm --version 2>$null
    if ($npmVersion) {
        Write-Host "✓ npm установлен: $npmVersion" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ npm не найден!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Установка зависимостей" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Установка зависимостей для Admin Panel
$adminPanelPath = Join-Path $PSScriptRoot "panels-source\admin-panel"
if (Test-Path $adminPanelPath) {
    Write-Host "Установка зависимостей для Admin Panel..." -ForegroundColor Yellow
    Set-Location $adminPanelPath
    if (-not (Test-Path "node_modules")) {
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Ошибка установки зависимостей для Admin Panel" -ForegroundColor Red
            exit 1
        }
        Write-Host "✓ Зависимости Admin Panel установлены" -ForegroundColor Green
    } else {
        Write-Host "✓ Зависимости Admin Panel уже установлены" -ForegroundColor Green
    }
} else {
    Write-Host "✗ Путь к Admin Panel не найден: $adminPanelPath" -ForegroundColor Red
}

Write-Host ""

# Установка зависимостей для Partner Panel
$partnerPanelPath = Join-Path $PSScriptRoot "panels-source\partner-panel"
if (Test-Path $partnerPanelPath) {
    Write-Host "Установка зависимостей для Partner Panel..." -ForegroundColor Yellow
    Set-Location $partnerPanelPath
    if (-not (Test-Path "node_modules")) {
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Ошибка установки зависимостей для Partner Panel" -ForegroundColor Red
            exit 1
        }
        Write-Host "✓ Зависимости Partner Panel установлены" -ForegroundColor Green
    } else {
        Write-Host "✓ Зависимости Partner Panel уже установлены" -ForegroundColor Green
    }
} else {
    Write-Host "✗ Путь к Partner Panel не найден: $partnerPanelPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Готово!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Для запуска панелей используйте:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Admin Panel:" -ForegroundColor Magenta
Write-Host "  cd panels-source\admin-panel" -ForegroundColor White
Write-Host "  npm run dev" -ForegroundColor White
Write-Host "  → http://localhost:3001" -ForegroundColor Green
Write-Host ""
Write-Host "Partner Panel:" -ForegroundColor Magenta
Write-Host "  cd panels-source\partner-panel" -ForegroundColor White
Write-Host "  npm run dev" -ForegroundColor White
Write-Host "  → http://localhost:3002" -ForegroundColor Green
Write-Host ""
Write-Host "Backend API уже работает на:" -ForegroundColor Cyan
Write-Host "  → http://localhost:8000" -ForegroundColor Green
Write-Host ""


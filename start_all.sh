#!/bin/bash
# Скрипт для запуска всех компонентов проекта (Linux/Mac)
# Использование: ./start_all.sh

echo "========================================"
echo "  YESS Money - Запуск всех сервисов"
echo "========================================"
echo ""

# Проверка Python
echo "Проверка Python..."
if ! command -v python3 &> /dev/null; then
    echo "✗ Python не найден! Установите Python 3.8+"
    exit 1
fi
echo "✓ Python $(python3 --version)"

# Проверка Node.js
echo "Проверка Node.js..."
if ! command -v node &> /dev/null; then
    echo "✗ Node.js не найден! Установите Node.js"
    exit 1
fi
echo "✓ Node.js $(node --version)"

echo ""

# Пути к проектам
BACKEND_PATH="yess-backend"
ADMIN_PANEL_PATH="panels-ts-v2/admin-panel"
PARTNER_PANEL_PATH="panels-ts-v2/partner-panel"

# Функция для запуска бэкенда
start_backend() {
    echo "🔧 Запуск Backend..."
    
    if [ ! -d "$BACKEND_PATH" ]; then
        echo "✗ Путь к бэкенду не найден: $BACKEND_PATH"
        return 1
    fi
    
    cd "$BACKEND_PATH"
    
    # Проверка виртуального окружения
    if [ ! -d "venv" ]; then
        echo "  Создание виртуального окружения..."
        python3 -m venv venv
    fi
    
    # Активация venv
    source venv/bin/activate
    
    # Установка зависимостей если нужно
    if [ ! -f "venv/bin/uvicorn" ]; then
        echo "  Установка зависимостей..."
        pip install -r requirements.txt
    fi
    
    # Запуск сервера в фоне
    echo "  Запуск сервера на http://localhost:8000..."
    uvicorn app.main:app --reload --port 8000 > /tmp/backend.log 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > /tmp/backend.pid
    
    cd ../..
    return 0
}

# Функция для запуска админ-панели
start_admin_panel() {
    echo "👨‍💼 Запуск Admin Panel..."
    
    if [ ! -d "$ADMIN_PANEL_PATH" ]; then
        echo "✗ Путь к админ-панели не найден: $ADMIN_PANEL_PATH"
        return 1
    fi
    
    cd "$ADMIN_PANEL_PATH"
    
    # Проверка node_modules
    if [ ! -d "node_modules" ]; then
        echo "  Установка зависимостей..."
        npm install
    fi
    
    # Запуск в фоне
    echo "  Запуск на http://localhost:3003..."
    npm run dev > /tmp/admin.log 2>&1 &
    ADMIN_PID=$!
    echo $ADMIN_PID > /tmp/admin.pid
    
    cd ../..
    return 0
}

# Функция для запуска партнер-панели
start_partner_panel() {
    echo "🤝 Запуск Partner Panel..."
    
    if [ ! -d "$PARTNER_PANEL_PATH" ]; then
        echo "✗ Путь к партнер-панели не найден: $PARTNER_PANEL_PATH"
        return 1
    fi
    
    cd "$PARTNER_PANEL_PATH"
    
    # Проверка node_modules
    if [ ! -d "node_modules" ]; then
        echo "  Установка зависимостей..."
        npm install
    fi
    
    # Запуск в фоне
    echo "  Запуск на http://localhost:3004..."
    npm run dev > /tmp/partner.log 2>&1 &
    PARTNER_PID=$!
    echo $PARTNER_PID > /tmp/partner.pid
    
    cd ../..
    return 0
}

# Обработка сигнала завершения
cleanup() {
    echo ""
    echo "Остановка сервисов..."
    if [ -f /tmp/backend.pid ]; then
        kill $(cat /tmp/backend.pid) 2>/dev/null
        rm /tmp/backend.pid
    fi
    if [ -f /tmp/admin.pid ]; then
        kill $(cat /tmp/admin.pid) 2>/dev/null
        rm /tmp/admin.pid
    fi
    if [ -f /tmp/partner.pid ]; then
        kill $(cat /tmp/partner.pid) 2>/dev/null
        rm /tmp/partner.pid
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

# Запуск всех сервисов
start_backend
sleep 2

start_admin_panel
sleep 2

start_partner_panel
sleep 2

echo ""
echo "========================================"
echo "  Сервисы запущены!"
echo "========================================"
echo ""
echo "📍 Доступные адреса:"
echo "  • Backend API:     http://localhost:8000"
echo "  • API Docs:        http://localhost:8000/docs"
echo "  • Admin Panel:     http://localhost:3003"
echo "  • Partner Panel:   http://localhost:3004"
echo ""
echo "💡 Логи:"
echo "  • Backend:   tail -f /tmp/backend.log"
echo "  • Admin:     tail -f /tmp/admin.log"
echo "  • Partner:   tail -f /tmp/partner.log"
echo ""
echo "Нажмите Ctrl+C для остановки всех сервисов"
echo ""

# Ожидание
wait


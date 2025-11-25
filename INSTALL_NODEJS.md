# Установка Node.js для запуска панелей

## Вариант 1: Через winget (Windows Package Manager) - Рекомендуется

```powershell
winget install OpenJS.NodeJS.LTS
```

После установки **перезапустите PowerShell** и проверьте:
```powershell
node --version
npm --version
```

## Вариант 2: Через Chocolatey

Если у вас установлен Chocolatey:
```powershell
choco install nodejs-lts
```

## Вариант 3: Ручная установка

1. Перейдите на https://nodejs.org/
2. Скачайте LTS версию (рекомендуется)
3. Установите с настройками по умолчанию
4. **Перезапустите PowerShell**

## После установки Node.js

Установите зависимости и запустите панели:

```powershell
# Admin Panel
cd D:\YessBackend-master\panels-source\admin-panel
npm install
npm run dev

# Partner Panel (в новом терминале)
cd D:\YessBackend-master\panels-source\partner-panel
npm install
npm run dev
```

## Порты

- Admin Panel: http://localhost:3001
- Partner Panel: http://localhost:3002
- Backend API: http://localhost:8000 (уже работает)


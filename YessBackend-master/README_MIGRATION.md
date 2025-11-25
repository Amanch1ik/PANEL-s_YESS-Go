# Миграция Backend на C#

## Дата миграции
22 ноября 2025

## Описание
Backend полностью переписан с Python (FastAPI) на C# (ASP.NET Core 8).

## Расположение
**Проект уже перемещен в:** `E:\YessProject — копия\yess-backend-dotnet\`

✅ Проект успешно скопирован и готов к работе!

## Структура проекта
- `YessBackend.Api` - API слой (контроллеры)
- `YessBackend.Application` - Бизнес-логика (сервисы, DTOs)
- `YessBackend.Domain` - Доменные сущности
- `YessBackend.Infrastructure` - Инфраструктура (EF Core, Redis, сервисы)

## Ключевые изменения

### API Endpoints
- `/api/v1/auth/login` - принимает `application/x-www-form-urlencoded` (OAuth2 стандарт)
- `/api/v1/auth/login/json` - для JSON запросов
- `/api/v1/payments/balance` - endpoint для баланса (совместимость с frontend)
- `/api/v1/health` - health check endpoint

### База данных
- Используется та же PostgreSQL база данных
- EF Core Migrations вместо Alembic
- Все таблицы и связи сохранены

### Docker
- Контейнер: `csharp-backend`
- Порты: HTTP 8000, HTTPS 8443
- docker-compose.yml в корне проекта

## Запуск

### Через Docker Compose (рекомендуется)
```bash
cd "E:\YessProject — копия\yess-backend-dotnet"
docker-compose up -d
```

### Локально (для разработки)
```bash
cd "E:\YessProject — копия\yess-backend-dotnet"
dotnet restore
dotnet build
dotnet run --project YessBackend.Api
```

## Важные заметки
- **Python backend больше не используется** - с этого дня работаем только с C# backend
- Все API endpoints полностью совместимы с предыдущей версией
- Swagger доступен по адресу `/docs` (если включен через переменную окружения `EnableSwagger=true`)

## Исправленные проблемы
1. ✅ Добавлен endpoint `/api/v1/payments/balance` для совместимости с frontend
2. ✅ Добавлен endpoint `/api/v1/health` для health checks
3. ✅ Исправлена обработка form-urlencoded в `/api/v1/auth/login`
4. ✅ Добавлен endpoint `/api/v1/auth/login/json` для JSON запросов


# 🚀 Быстрое исправление проблемы с PostgreSQL

## Проблема
Backend не может подключиться к PostgreSQL: `28P01: password authentication failed`

## ✅ Решение за 2 шага

### Шаг 1: Запустите PostgreSQL через Docker

```bash
cd yess-backend-dotnet
docker-compose up -d postgres
```

Или используйте скрипт:
```bash
START_POSTGRESQL.bat
```

### Шаг 2: Обновите пароль в appsettings.json

Измените строку подключения на:
```json
"DefaultConnection": "Host=localhost;Port=5432;Database=yess_db;Username=yess_user;Password=secure_password"
```

### Шаг 3: Запустите backend

```bash
dotnet run --project YessBackend.Api\YessBackend.Api.csproj
```

Миграции применятся автоматически, таблица `users` будет создана, и login будет работать!

---

## Альтернатива: Использовать локальный PostgreSQL

Если у вас уже установлен PostgreSQL локально:

1. Создайте пользователя и базу данных:
   ```sql
   psql -U postgres -f SETUP_POSTGRESQL.sql
   ```

2. Connection string уже настроен на пароль `password` в `appsettings.json`

3. Запустите backend - миграции применятся автоматически


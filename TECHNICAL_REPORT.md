# Технический отчёт: YESS Go — состояние проекта и деплой

**Дата составления:** 2024-12-XX  
**Составитель:** DevOps Engineering Team  
**Проект:** YESS Go Loyalty System  
**Путь на сервере:** `/PANEL-s_YESS-Go` (или эквивалентный)

---

## 1. Архитектура проекта

### 1.0. Структура доменов

| Домен | Назначение | Сервис |
|-------|------------|--------|
| `yessgo.org` / `www.yessgo.org` | Landing page | Static files |
| `api.yessgo.org` | Backend API | C# Backend (порт 5000) |
| `admin.yessgo.org` | Админ-панель | Admin Panel SPA |
| `partner.yessgo.org` | Панель партнёра | Partner Panel SPA |

**Конфигурация Nginx:** См. `nginx/nginx.domains.conf` и `DOMAIN_ROUTING.md`

## 1. Архитектура проекта

### 1.1. Общая структура

Проект YESS Go представляет собой комплексную систему лояльности, состоящую из:

- **Backend API**: ASP.NET Core (C#) — основной backend
- **Admin Panel**: React + TypeScript SPA для администраторов
- **Partner Panel**: React + TypeScript SPA для партнёров
- **Database**: PostgreSQL 15
- **Cache**: Redis 7
- **Reverse Proxy**: Nginx
- **Containerization**: Docker + Docker Compose

### 1.2. Компоненты системы

#### Backend Services

1. **C# Backend (ASP.NET Core)**
   - Путь: `./YessBackend-master/`
   - Порт: `8000` (HTTP), `8443` (HTTPS)
   - Контейнер: `yess-backend-prod`
   - Технологии: .NET 8.0, Entity Framework Core, PostgreSQL

2. **Python FastAPI Backend (legacy/dev)**
   - Путь: `./yess-backend/`
   - Порт: `8001` (dev mode)
   - Контейнер: `yess-backend`
   - Статус: используется для разработки, не в production

#### Frontend Panels

1. **Admin Panel (активная версия)**
   - Путь: `./panels-ts-v2/admin-panel/`
   - Порт: `8083` (production)
   - Контейнер: `yess-admin-panel-prod`
   - Технологии: React 18.2, TypeScript 5.3, Vite 5.0, Ant Design 5.12

2. **Partner Panel (активная версия)**
   - Путь: `./panels-ts-v2/partner-panel/`
   - Порт: `8081` (production)
   - Контейнер: `yess-partner-panel-prod`
   - Технологии: React 18.2, TypeScript 5.3, Vite 5.0, Ant Design 5.12

3. **Legacy панели (не используются в production)**
   - `./admin-panel/` — старая версия
   - `./partner-panel/` — старая версия
   - `./Yess-Money---app-master/admin-panel/` — архивная версия
   - Статус: присутствуют в репозитории, но не деплоятся

#### Infrastructure Services

1. **PostgreSQL**
   - Порт: `5432`
   - Контейнер: `yess-postgres-prod`
   - Volume: `yess_pg_data_prod`

2. **Redis**
   - Порт: `6379`
   - Контейнер: `yess-redis-prod`
   - Volume: `yess_redis_data_prod`

3. **Nginx (опционально)**
   - Порт: `80` (HTTP), `443` (HTTPS)
   - Конфигурация: `./nginx/nginx.conf`
   - Назначение: reverse proxy для объединения сервисов

### 1.3. Docker Compose конфигурации

В проекте присутствуют несколько файлов Docker Compose:

1. **`docker-compose.yml`** (development)
   - PostgreSQL: `5433:5432` (изменён порт для избежания конфликтов)
   - Redis: `6380:6379`
   - Python Backend: `8001:8000`
   - PgAdmin: `5050:80`

2. **`docker-compose.prod.yml`** (production)
   - PostgreSQL: `5432:5432`
   - Redis: `6379:6379`
   - C# Backend: `8000:8000`
   - Admin Panel: `8083:80`
   - Partner Panel: `8081:80`

3. **`panels-ts-v2/docker-compose.prod.yml`** (альтернативная конфигурация)
   - Содержит те же сервисы, но с другим контекстом сборки

---

## 2. Физическое расположение панелей на сервере

### 2.1. Production панели (используются)

**Admin Panel:**
- **Исходный код:** `/PANEL-s_YESS-Go/panels-ts-v2/admin-panel/`
- **Dockerfile:** `/PANEL-s_YESS-Go/panels-ts-v2/admin-panel/Dockerfile`
- **Собранная статика:** Внутри Docker образа, монтируется в `/usr/share/nginx/html`
- **Nginx конфигурация:** `/PANEL-s_YESS-Go/panels-ts-v2/admin-panel/nginx.conf`
- **Доступ:** `http://server:8083` или через Nginx reverse proxy

**Partner Panel:**
- **Исходный код:** `/PANEL-s_YESS-Go/panels-ts-v2/partner-panel/`
- **Dockerfile:** `/PANEL-s_YESS-Go/panels-ts-v2/partner-panel/Dockerfile`
- **Собранная статика:** Внутри Docker образа, монтируется в `/usr/share/nginx/html`
- **Nginx конфигурация:** `/PANEL-s_YESS-Go/panels-ts-v2/partner-panel/nginx.conf`
- **Доступ:** `http://server:8081` или через Nginx reverse proxy

### 2.2. Legacy панели ✅ УДАЛЕНЫ

Legacy панели были удалены для упрощения структуры проекта:
- ~~`/PANEL-s_YESS-Go/admin-panel/`~~ — удалена (legacy версия)
- ~~`/PANEL-s_YESS-Go/partner-panel/`~~ — удалена (legacy версия)
- ~~`/PANEL-s_YESS-Go/Yess-Money---app-master/partner-panel/`~~ — удалена (архивная версия)

**Статус:** Все активные панели находятся в `panels-ts-v2/`.

### 2.3. Сборка и деплой панелей

**Процесс сборки:**

1. **Build stage:** 
   - Dockerfile копирует исходный код из `panels-ts-v2/admin-panel/`
   - Устанавливает зависимости через `npm ci`
   - Выполняет сборку: `npm run build:prod` (TypeScript компиляция + Vite build)

2. **Runtime stage:**
   - Использует `nginx:1.27-alpine` как базовый образ
   - Копирует собранную статику из build stage
   - Применяет nginx.conf для SPA routing
   - Проксирует API запросы на `csharp-backend:5000` (внутренний порт в Docker сети)

**Важно:** Собранная статика находится только внутри Docker образа. Файлы не монтируются через volumes, что означает необходимость пересборки образа при изменениях.

---

## 3. Синхронизация с GitHub и процесс деплоя

### 3.1. Текущий процесс синхронизации

**Операции, которые были выполнены:**

```bash
# 1. Получение изменений из удалённого репозитория
git fetch origin

# 2. Жёсткий сброс локальной ветки к состоянию удалённой ветки main
git reset --hard origin/main
```

### 3.2. Объяснение команд

**`git fetch origin`:**
- Получает все изменения из удалённого репозитория (GitHub)
- Не изменяет локальную рабочую директорию
- Обновляет ссылки на удалённые ветки (origin/main, origin/master и т.д.)

**`git reset --hard origin/main`:**
- Сбрасывает текущую ветку (HEAD) к состоянию `origin/main`
- Удаляет все локальные изменения, которые не закоммичены
- Удаляет все локальные коммиты, которых нет в `origin/main`
- Жёсткий режим (`--hard`) также очищает рабочую директорию

### 3.3. Почему возник конфликт divergent branches

**Причина возникновения:**

Конфликт divergent branches возникает, когда:
1. На сервере были выполнены локальные коммиты (изменения конфигурации, дебаг-изменения и т.д.)
2. В GitHub репозитории были выполнены другие коммиты (обновления от разработчиков)
3. Локальная ветка и удалённая ветка разошлись (diverged) — имеют разные истории коммитов

**Типичные сценарии:**

- Изменения конфигурации на сервере (docker-compose.yml, .env файлы)
- Hotfix-изменения, выполненные напрямую на сервере
- Откат к предыдущей версии через `git reset`
- Параллельная работа нескольких разработчиков

### 3.4. Правильное решение конфликта

**Вариант 1: Сохранить изменения сервера (если они важны)**

```bash
# 1. Сохранить локальные изменения
git stash

# 2. Получить удалённые изменения
git fetch origin

# 3. Объединить изменения
git merge origin/main

# 4. Применить сохранённые изменения
git stash pop

# 5. Разрешить конфликты вручную
# 6. Закоммитить и запушить
```

**Вариант 2: Принять удалённые изменения (использовано в данном случае)**

```bash
# 1. Получить удалённые изменения
git fetch origin

# 2. Жёсткий сброс к удалённой ветке (УДАЛЯЕТ локальные изменения)
git reset --hard origin/main
```

**Выбор варианта 2 был корректен, если:**
- Локальные изменения на сервере не критичны
- Все важные изменения уже в GitHub
- Требуется точное соответствие сервера и репозитория

**Риски варианта 2:**
- Удаление локальных изменений конфигурации
- Потеря дебаг-изменений
- Необходимость восстановления конфигурации после reset

### 3.5. Рекомендуемый процесс деплоя

**Идеальный workflow:**

```bash
# 1. Проверить статус репозитория
git status
git log --oneline -10

# 2. Сохранить важные локальные изменения (если есть)
git diff > /tmp/local-changes.patch
# Или для конфигурационных файлов:
cp docker-compose.prod.yml docker-compose.prod.yml.local

# 3. Получить изменения
git fetch origin

# 4. Посмотреть различия
git log HEAD..origin/main --oneline
git diff HEAD origin/main

# 5. Выполнить синхронизацию (выбрать стратегию)
# Вариант A: Merge (сохраняет историю)
git merge origin/main

# Вариант B: Rebase (чистая история)
git rebase origin/main

# Вариант C: Reset (жесткий сброс, используется при конфликтах)
git reset --hard origin/main

# 6. Восстановить локальные изменения конфигурации (если нужно)
# 7. Пересобрать и перезапустить контейнеры
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build
```

---

## 4. Риски текущей архитектуры

### 4.1. Дублирование панелей ✅ ИСПРАВЛЕНО

**Решение:**
Legacy версии панелей были удалены из репозитория:
- ✅ Оставлены только активные панели в `panels-ts-v2/`
- ✅ Удалены `admin-panel/` и `partner-panel/` (legacy версии)
- ✅ Удалена архивная версия `Yess-Money---app-master/partner-panel/`

**Результат:**
- Нет путаницы при деплое
- Уменьшен размер репозитория
- Все панели используют единый путь `panels-ts-v2/`

### 4.2. Коммиты на сервере

**Проблема:**
Локальные коммиты на сервере создают divergent branches.

**Риски:**
- Конфликты при синхронизации
- Потеря изменений при `git reset --hard`
- Невозможность отследить источник изменений
- Нарушение принципа "serverless deployments"

**Рекомендация:**
- **Никогда не коммитить на сервере**
- Использовать отдельные файлы для конфигурации (`.env.local`, `docker-compose.override.yml`)
- Включить `.env.local` в `.gitignore`
- Использовать environment variables или secrets management

### 4.3. Отсутствие CI/CD

**Проблема:**
Деплой выполняется вручную через SSH + git команды.

**Риски:**
- Человеческие ошибки при деплое
- Нет автоматического тестирования перед деплоем
- Нет автоматического rollback при ошибках
- Долгое время восстановления при проблемах

**Рекомендация:**
- Настроить GitHub Actions или GitLab CI/CD
- Автоматический деплой при push в `main` ветку
- Автоматическая сборка Docker образов
- Health checks после деплоя
- Автоматический rollback при неудаче

### 4.4. Отсутствие версионирования образов

**Проблема:**
Docker образы собираются без тегов версий, используются `latest` или вообще без тегов.

**Риски:**
- Невозможность откатиться к предыдущей версии
- Непредсказуемое поведение при пересборке
- Сложность отладки проблем

**Рекомендация:**
- Использовать семантическое версионирование: `v1.2.3`
- Тегировать образы при каждом деплое
- Хранить образы в container registry (Docker Hub, GitHub Container Registry)
- Использовать теги: `latest`, `v1.2.3`, `main-abc123` (commit hash)

### 4.5. Конфигурация в коде

**Проблема:**
Конфигурация (порты, URLs) захардкожена в docker-compose файлах.

**Риски:**
- Необходимость изменять код для изменения конфигурации
- Разные конфигурации для разных окружений
- Риск случайного коммита production конфигурации

**Рекомендация:**
- Использовать `.env` файлы
- Использовать docker-compose override файлы
- Использовать secrets management (Docker Secrets, HashiCorp Vault)
- Разделить конфигурацию по окружениям (dev, staging, prod)

### 4.6. Отсутствие мониторинга

**Проблема:**
Нет централизованного мониторинга состояния сервисов.

**Риски:**
- Проблемы обнаруживаются только при жалобах пользователей
- Нет метрик производительности
- Нет алертов при падении сервисов

**Рекомендация:**
- Настроить Prometheus + Grafana
- Health checks для всех сервисов
- Логирование в централизованную систему (ELK, Loki)
- Алерты при критических ошибках

---

## 5. Рекомендации по улучшению деплоя

### 5.1. Стратегия ветвления

**Рекомендация: GitFlow или GitHub Flow**

```
main (production)
  ├── develop (development)
  ├── feature/* (новые функции)
  ├── hotfix/* (критические исправления)
  └── release/* (подготовка релизов)
```

**Процесс:**
1. Разработка ведётся в `develop`
2. При готовности — merge в `main`
3. Автоматический деплой из `main` на production
4. Hotfix делаются напрямую в `main` или через отдельную ветку

### 5.2. CI/CD Pipeline

**Пример GitHub Actions workflow:**

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker images
        run: |
          docker build -t admin-panel:${GITHUB_SHA} ./panels-ts-v2/admin-panel
          docker build -t partner-panel:${GITHUB_SHA} ./panels-ts-v2/partner-panel
      
      - name: Push to registry
        run: |
          docker push admin-panel:${GITHUB_SHA}
          docker push partner-panel:${GITHUB_SHA}
      
      - name: Deploy to server
        run: |
          ssh user@server 'cd /PANEL-s_YESS-Go && \
            git pull origin main && \
            docker-compose -f docker-compose.prod.yml pull && \
            docker-compose -f docker-compose.prod.yml up -d'
```

### 5.3. Версионирование и тегирование

**Рекомендация:**

```bash
# При релизе
git tag -a v1.2.3 -m "Release version 1.2.3"
git push origin v1.2.3

# Сборка с тегом
docker build -t admin-panel:v1.2.3 ./panels-ts-v2/admin-panel
docker tag admin-panel:v1.2.3 admin-panel:latest
docker push admin-panel:v1.2.3
docker push admin-panel:latest
```

### 5.4. Конфигурация через переменные окружения

**Рекомендация:**

Создать `.env.production` файл (не коммитить в git):

```bash
# .env.production
POSTGRES_USER=yess_user
POSTGRES_PASSWORD=secure_password
POSTGRES_DB=yess_db
BACKEND_PORT=8000
ADMIN_PANEL_PORT=8083
PARTNER_PANEL_PORT=8081
JWT_SECRET_KEY=your-secret-key
```

Использовать в docker-compose:

```yaml
services:
  admin-panel:
    ports:
      - "${ADMIN_PANEL_PORT:-8083}:80"
```

### 5.5. Health Checks и Monitoring

**Рекомендация:**

Добавить health check endpoints во все сервисы:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

Настроить Prometheus для мониторинга.

### 5.6. Backup стратегия

**Рекомендация:**

1. **Database backups:**
   ```bash
   # Ежедневный backup
   0 2 * * * docker exec yess-postgres-prod pg_dump -U yess_user yess_db > /backup/db_$(date +\%Y\%m\%d).sql
   ```

2. **Configuration backups:**
   - Версионирование всех конфигураций в git
   - Резервное копирование `.env` файлов (в зашифрованном виде)

3. **Docker volumes:**
   - Регулярное backup томов PostgreSQL и Redis

### 5.7. Документация деплоя

**Рекомендация:**

Создать `DEPLOYMENT.md` с пошаговой инструкцией:

```markdown
# Deployment Guide

## Prerequisites
- Docker and Docker Compose installed
- Git installed
- SSH access to server

## Deployment Steps

1. SSH to server
2. cd /PANEL-s_YESS-Go
3. git pull origin main
4. docker-compose -f docker-compose.prod.yml up -d --build
5. Verify services: docker-compose ps
6. Check logs: docker-compose logs -f
```

---

## 6. Итоговое состояние системы после синхронизации

### 6.1. Состояние репозитория

После выполнения `git reset --hard origin/main`:

- ✅ Локальная ветка полностью соответствует `origin/main`
- ✅ Все локальные изменения удалены
- ✅ Рабочая директория чистая (нет uncommitted changes)
- ⚠️ Локальные конфигурационные изменения (если были) потеряны

### 6.2. Структура проекта на сервере

```
/PANEL-s_YESS-Go/
├── panels-ts-v2/                   # ✅ Активные панели
│   ├── admin-panel/                # Production admin panel (порт 3003)
│   └── partner-panel/              # Production partner panel (порт 3004)
├── yess-backend/                   # Python backend (dev)
├── YessBackend-master/             # ✅ C# backend (production)
├── docker-compose.yml              # Dev configuration
├── docker-compose.prod.yml         # ✅ Production configuration
└── nginx/                          # Nginx configuration
```

### 6.3. Запущенные сервисы

После синхронизации и перезапуска должны быть активны:

- `yess-postgres-prod` — PostgreSQL на порту 5432
- `yess-redis-prod` — Redis на порту 6379
- `yess-backend-prod` — C# Backend на порту 8000
- `yess-admin-panel-prod` — Admin Panel на порту 8083
- `yess-partner-panel-prod` — Partner Panel на порту 8081

### 6.4. Проверка состояния

**Команды для проверки:**

```bash
# Статус репозитория
git status
git log --oneline -5

# Статус Docker контейнеров
docker-compose -f docker-compose.prod.yml ps

# Логи сервисов
docker-compose -f docker-compose.prod.yml logs --tail=50 admin-panel
docker-compose -f docker-compose.prod.yml logs --tail=50 partner-panel
docker-compose -f docker-compose.prod.yml logs --tail=50 csharp-backend

# Health checks
curl http://localhost:8083/health  # Admin panel
curl http://localhost:8081/health  # Partner panel
curl http://localhost:8000/api/v1/health  # Backend
```

### 6.5. Следующие шаги

1. **Восстановить конфигурацию** (если были локальные изменения)
   - Проверить `.env` файлы
   - Проверить `docker-compose.prod.yml` на предмет кастомных настроек

2. **Пересобрать контейнеры** (если были изменения в коде)
   ```bash
   docker-compose -f docker-compose.prod.yml up -d --build
   ```

3. **Проверить работоспособность**
   - Открыть панели в браузере
   - Проверить API endpoints
   - Проверить логи на ошибки

4. **Настроить мониторинг** (рекомендуется)
   - Настроить health checks
   - Настроить алерты
   - Настроить логирование

---

## 7. Выводы

### Текущее состояние

- ✅ Репозиторий синхронизирован с GitHub
- ✅ Структура проекта определена
- ✅ Production панели находятся в `panels-ts-v2/`
- ✅ Legacy панели удалены (упрощена структура)
- ⚠️ Отсутствует автоматизация деплоя
- ⚠️ Нет версионирования Docker образов

### Критические риски

1. **Коммиты на сервере** — могут вызывать конфликты
2. ~~**Дублирование панелей**~~ ✅ **ИСПРАВЛЕНО** — legacy панели удалены
3. **Отсутствие CI/CD** — ручной деплой подвержен ошибкам
4. **Нет мониторинга** — проблемы обнаруживаются поздно

### Приоритетные улучшения

1. **Немедленно:**
   - Документировать процесс деплоя
   - Добавить `.env` файлы для конфигурации
   - Настроить health checks

2. **Краткосрочно (1-2 недели):**
   - Настроить CI/CD pipeline
   - Версионировать Docker образы
   - ~~Очистить legacy панели~~ ✅ **ВЫПОЛНЕНО**

3. **Долгосрочно (1-2 месяца):**
   - Настроить мониторинг (Prometheus + Grafana)
   - Реализовать автоматический rollback
   - Настроить backup стратегию

---

**Конец отчёта**


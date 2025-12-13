# Домены YESS Go

## Структура доменов

| Домен | Назначение | Что показывает |
|-------|------------|----------------|
| `yessgo.org` / `www.yessgo.org` | Landing page | Заглушка / landing |
| `api.yessgo.org` | Backend API | Backend API (C# ASP.NET Core) |
| `admin.yessgo.org` | Админ-панель | Admin Panel (SPA) |
| `partner.yessgo.org` | Панель партнёра | Partner Panel (SPA) |

## Конфигурация

- **Nginx конфигурация:** `nginx/nginx.domains.conf`
- **Docker Compose:** `docker-compose.nginx.yml`
- **Документация:** `DOMAIN_ROUTING.md`, `DEPLOYMENT_DOMAINS.md`

## Запуск

```bash
# Запуск всех сервисов с поддержкой доменов
docker-compose -f docker-compose.prod.yml -f docker-compose.nginx.yml up -d
```

## Важно

1. Панели (admin-panel, partner-panel) **не публикуют порты наружу** - доступ только через Nginx
2. Nginx проксирует запросы на контейнеры через Docker сеть
3. Все сервисы должны быть в одной сети `yess-network-prod`


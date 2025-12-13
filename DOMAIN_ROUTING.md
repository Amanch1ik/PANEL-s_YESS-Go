# Конфигурация доменов YESS Go

## Структура доменов

| Домен | Назначение | Сервис | Порт (внутри Docker) |
|-------|------------|--------|---------------------|
| `yessgo.org` | Landing page / заглушка | Static files | 80 |
| `www.yessgo.org` | То же, что yessgo.org | Static files | 80 |
| `api.yessgo.org` | Backend API | C# Backend | 5000 |
| `admin.yessgo.org` | Админ-панель (SPA) | Admin Panel | 80 (nginx) |
| `partner.yessgo.org` | Панель партнёра (SPA) | Partner Panel | 80 (nginx) |

## Настройка Nginx

### Конфигурационный файл

Конфигурация находится в: `nginx/nginx.domains.conf`

### Основные настройки

1. **api.yessgo.org**
   - Проксирует все запросы на `csharp-backend:5000`
   - Поддерживает WebSocket (`/api/v1/ws`)
   - Swagger доступен по `/docs`

2. **admin.yessgo.org**
   - Раздаёт статику Admin Panel из `/usr/share/nginx/html`
   - Проксирует `/api` запросы на backend
   - SPA routing (все запросы → `index.html`)

3. **partner.yessgo.org**
   - Раздаёт статику Partner Panel из `/usr/share/nginx/html`
   - Проксирует `/api` запросы на backend
   - SPA routing (все запросы → `index.html`)

4. **yessgo.org / www.yessgo.org**
   - Раздаёт статику landing page из `/var/www/landing`

## Docker Compose конфигурация

Используйте файл `docker-compose.nginx.yml` для запуска Nginx с поддержкой доменов:

```bash
docker-compose -f docker-compose.prod.yml -f docker-compose.nginx.yml up -d
```

**Важно:** Панели (admin-panel и partner-panel) должны быть запущены из `docker-compose.prod.yml`, но **не должны публиковать порты** наружу. Nginx проксирует запросы через Docker сеть.

### Обновлённая конфигурация панелей в docker-compose.prod.yml:

```yaml
admin-panel:
  # ... существующая конфигурация ...
  # УБРАТЬ строку ports, чтобы панель была доступна только через nginx
  # ports:
  #   - "0.0.0.0:8083:80"  # УДАЛИТЬ эту строку
  networks:
    - yess-network-prod

partner-panel:
  # ... существующая конфигурация ...
  # УБРАТЬ строку ports, чтобы панель была доступна только через nginx
  # ports:
  #   - "0.0.0.0:8081:80"  # УДАЛИТЬ эту строку
  networks:
    - yess-network-prod
```

### Имена контейнеров в Nginx:

Nginx использует имена сервисов из docker-compose:
- `csharp-backend` - для API
- `admin-panel` - для Admin Panel
- `partner-panel` - для Partner Panel

Убедитесь, что в `docker-compose.prod.yml` сервисы имеют правильные имена.

## DNS настройка

Необходимо настроить A-записи для всех поддоменов:

```
yessgo.org           A    <SERVER_IP>
www.yessgo.org       A    <SERVER_IP>
api.yessgo.org       A    <SERVER_IP>
admin.yessgo.org     A    <SERVER_IP>
partner.yessgo.org   A    <SERVER_IP>
```

## SSL/TLS сертификаты

Для включения HTTPS:

1. Получить SSL сертификаты (Let's Encrypt):
```bash
certbot certonly --nginx -d yessgo.org -d www.yessgo.org -d api.yessgo.org -d admin.yessgo.org -d partner.yessgo.org
```

2. Обновить конфигурацию nginx для использования SSL (раскомментировать HTTPS секции)

3. Добавить редирект HTTP → HTTPS

## Проверка конфигурации

```bash
# Проверить синтаксис nginx
nginx -t -c /path/to/nginx.domains.conf

# Проверить доступность доменов
curl -H "Host: api.yessgo.org" http://localhost/api/v1/health
curl -H "Host: admin.yessgo.org" http://localhost/
curl -H "Host: partner.yessgo.org" http://localhost/
```

## Логи

Логи Nginx доступны в контейнере:
```bash
docker exec yess-nginx tail -f /var/log/nginx/access.log
docker exec yess-nginx tail -f /var/log/nginx/error.log
```


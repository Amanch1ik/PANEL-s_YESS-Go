# Деплой с доменами yessgo.org

## Структура доменов

| Домен | Назначение | Порт (публичный) |
|-------|------------|------------------|
| `yessgo.org` / `www.yessgo.org` | Landing page | 80 (HTTP), 443 (HTTPS) |
| `api.yessgo.org` | Backend API | 80 (HTTP), 443 (HTTPS) |
| `admin.yessgo.org` | Админ-панель | 80 (HTTP), 443 (HTTPS) |
| `partner.yessgo.org` | Панель партнёра | 80 (HTTP), 443 (HTTPS) |

## Быстрый старт

### 1. Запуск всех сервисов с Nginx

```bash
cd PANEL-s_YESS-Go
docker-compose -f docker-compose.prod.yml -f docker-compose.nginx.yml up -d
```

### 2. Проверка работы

```bash
# Проверка контейнеров
docker-compose -f docker-compose.prod.yml -f docker-compose.nginx.yml ps

# Проверка логов Nginx
docker logs yess-nginx

# Проверка доступности доменов (локально)
curl -H "Host: api.yessgo.org" http://localhost/api/v1/health
curl -H "Host: admin.yessgo.org" http://localhost/
curl -H "Host: partner.yessgo.org" http://localhost/
```

## DNS настройка

Настройте A-записи для всех поддоменов на IP адрес сервера:

```
yessgo.org           A    <SERVER_IP>
www.yessgo.org       A    <SERVER_IP>
api.yessgo.org       A    <SERVER_IP>
admin.yessgo.org     A    <SERVER_IP>
partner.yessgo.org   A    <SERVER_IP>
```

## SSL/TLS сертификаты

### Получение сертификатов Let's Encrypt

```bash
# Установка certbot (если не установлен)
sudo apt-get update
sudo apt-get install certbot

# Получение сертификатов для всех доменов
sudo certbot certonly --nginx \
  -d yessgo.org \
  -d www.yessgo.org \
  -d api.yessgo.org \
  -d admin.yessgo.org \
  -d partner.yessgo.org

# Сертификаты будут сохранены в:
# /etc/letsencrypt/live/yessgo.org/fullchain.pem
# /etc/letsencrypt/live/yessgo.org/privkey.pem
```

### Обновление Nginx конфигурации для HTTPS

Раскомментируйте HTTPS секции в `nginx/nginx.domains.conf` и обновите пути к сертификатам.

### Автоматическое обновление сертификатов

```bash
# Добавить в crontab
sudo crontab -e

# Добавить строку (обновление каждый месяц)
0 3 1 * * certbot renew --quiet && docker restart yess-nginx
```

## Архитектура

```
┌─────────────────────────────────────────┐
│         Internet / DNS                  │
└───────────────┬─────────────────────────┘
                │
        ┌───────▼────────┐
        │   Nginx        │
        │  (Port 80/443) │
        └───┬───┬───┬────┘
            │   │   │
    ┌───────┘   │   └──────────┐
    │           │              │
┌───▼───┐  ┌───▼───┐     ┌────▼─────┐
│ Admin │  │Partner│     │   API    │
│ Panel │  │ Panel │     │ Backend  │
└───────┘  └───────┘     └──────────┘
```

## Важные моменты

1. **Панели не публикуют порты наружу** - они доступны только через Nginx
2. **Nginx проксирует API запросы** на `csharp-backend:5000` 
3. **Landing page** должна быть в директории `/var/www/landing` на хосте
4. **Все сервисы в одной Docker сети** `yess-network-prod`

## Troubleshooting

### Домены не открываются

1. Проверьте DNS записи:
   ```bash
   nslookup api.yessgo.org
   nslookup admin.yessgo.org
   ```

2. Проверьте конфигурацию Nginx:
   ```bash
   docker exec yess-nginx nginx -t
   ```

3. Проверьте логи:
   ```bash
   docker logs yess-nginx
   docker logs yess-admin-panel-prod
   docker logs yess-partner-panel-prod
   ```

### 502 Bad Gateway

1. Проверьте, что контейнеры запущены:
   ```bash
   docker ps | grep -E "admin-panel|partner-panel|csharp-backend"
   ```

2. Проверьте доступность сервисов из Nginx контейнера:
   ```bash
   docker exec yess-nginx wget -O- http://admin-panel:80/health
   docker exec yess-nginx wget -O- http://csharp-backend:5000/api/v1/health
   ```

3. Проверьте Docker сеть:
   ```bash
   docker network inspect yess-network-prod
   ```

### SSL ошибки

1. Проверьте, что сертификаты смонтированы:
   ```bash
   docker exec yess-nginx ls -la /etc/letsencrypt/live/
   ```

2. Проверьте права доступа к сертификатам


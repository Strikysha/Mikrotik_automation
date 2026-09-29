# Mikrotik automation

Скрипт загружает списки IPv4 и IPv6 сетей с сайта Beltelecom и сохраняет их в файлы `IPv4_list.txt` и `IPv6_list.txt`.

## Запуск скрипта вручную

### 1. Установка зависимостей

Создайте виртуальное окружение (рекомендуется):

```bash
python3 -m venv venv
source venv/bin/activate   # Linux/macOS
# или на Windows: venv\Scripts\activate
```

Установите библиотеки:

```bash
pip3 install requests beautifulsoup4
```

(На macOS часто доступен именно `pip3`; если есть только `pip`, используйте его.)

### 2. Запуск

Перейдите в каталог проекта и выполните:

```bash
cd /путь/к/Mikrotik_automation
python3 fetch_ips.py
```

Скрипт скачает страницу, распарсит блоки с адресами и перезапишет файлы `IPv4_list.txt` и `IPv6_list.txt` в текущей директории (без лишних пробелов в строках).

### 3. Результат

- `IPv4_list.txt` — список IPv4-сетей (CIDR)
- `IPv6_list.txt` — список IPv6-сетей (CIDR)

Строки в файлах без ведущих и завершающих пробелов; пустые строки не записываются.

## Автообновление (GitHub Actions)

`fetch_ips.py` также запускается автоматически: `.github/workflows/fetch_ip_lists.yml`
дёргает его каждый день в 00:00 UTC (плюс при пуше в `main` и вручную через
`workflow_dispatch`) и коммитит `IPv4_list.txt`/`IPv6_list.txt`, если они
изменились. Ничего руками запускать не нужно — списки в репозитории уже
актуальны.

## Роутер: bynets_v4 / bynets_v6

`bynets_v4.rsc` и `bynets_v6.rsc` — это версии RouterOS-скриптов, которые
реально стоят на роутере: они по расписанию скачивают `IPv4_list.txt` /
`IPv6_list.txt` с `raw.githubusercontent.com` и пересобирают firewall
address-list'ы `bynets_v4` / `bynets_v6`.

Чтобы поднять их на роутере с нуля (или после того, как скрипты/задачи
планировщика были удалены), залейте `provision_router.rsc` в Files роутера
и выполните:

```
/import file-name=provision_router.rsc
```

Скрипт идемпотентный: пересоздаёт `/system script` bynets_v4/bynets_v6 из
файлов этого репозитория и `/system scheduler` задачи, которые их
ежедневно запускают (04:00 / 04:05 по местному времени роутера — с запасом
после того, как GitHub Action обновит списки в 00:00 UTC). При изменении
`bynets_v4.rsc`/`bynets_v6.rsc` в репозитории — повторный запуск
`provision_router.rsc` подтянет обновлённую версию на роутер.

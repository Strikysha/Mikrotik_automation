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

import requests
from bs4 import BeautifulSoup

def fetch_ips(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')

    # Предполагаем, что таблица находится в теге <pre>
    pre_tag = soup.find('pre')
    
    # Обрабатываем текст внутри <pre> для извлечения IP-адресов
    ipv4_list = []
    ipv6_list = []
    for line in pre_tag.text.split("\n"):
        # Отделим IPv4 и IPv6 на основании символа ':'
        if ':' in line:
            # Это IPv6 адрес
            ipv6_list.append(line.strip())
        elif line.strip():
            # Это IPv4 адрес
            ipv4_list.append(line.strip())

    # Сохраняем списки в файлы
    with open('IPv4_list.txt', 'w') as f:
        f.write("\n".join(ipv4_list))
    with open('IPv6_list.txt', 'w') as f:
        f.write("\n".join(ipv6_list))

if __name__ == '__main__':
    url = 'https://beltelecom.by/business/hosting/belnetworks'
    fetch_ips(url)
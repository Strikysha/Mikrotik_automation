import requests
from bs4 import BeautifulSoup

def fetch_ips(url):
    response = requests.get(url)
    response.encoding = response.apparent_encoding  # Устраняем проблемы с кодировкой
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Находим все элементы <pre>
    pre_tags = soup.find_all('pre')

    # На случай, если порядок столбцов изменится, более надёжно присвоить списки после проверки содержимого.
    ipv4_list = []
    ipv6_list = []

    for pre in pre_tags:
        if '.' in pre.text:
            ipv4_list += pre.text.strip().split("\n")
        elif ':' in pre.text:
            ipv6_list += pre.text.strip().split("\n")

    # Сохраняем списки в файлы
    with open('IPv4_list.txt', 'w') as ipv4_file:
        ipv4_file.write("\n".join(ipv4_list))
    with open('IPv6_list.txt', 'w') as ipv6_file:
        ipv6_file.write("\n".join(ipv6_list))

if __name__ == '__main__':
    url = 'https://beltelecom.by/business/hosting/belnetworks'
    fetch_ips(url)
"""
HTTP-клиент для работы с внешними API
"""
import requests


class ApiClient:
    """Клиент для HTTP-запросов"""

    CBR_URL = "https://www.cbr-xml-daily.ru/daily_json.js"

    @staticmethod
    def get_currency_rates():
        """
        Получение курсов валют с сайта ЦБ РФ
        Возвращает dict или None
        """
        try:
            response = requests.get(ApiClient.CBR_URL, timeout=5)
            response.raise_for_status()
            data = response.json()

            valutes = data.get("Valute", {})
            return {
                "USD": valutes.get("USD", {}).get("Value"),
                "EUR": valutes.get("EUR", {}).get("Value"),
                "CNY": valutes.get("CNY", {}).get("Value"),
            }

        except Exception as e:
            print(f"Ошибка HTTP-запроса: {e}")
            return None

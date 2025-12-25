"""
Менеджер для работы с заказами
"""
import json
from datetime import datetime
from typing import List, Dict, Any, Optional

class OrderManager:
    """Менеджер заказов"""
    
    def __init__(self, db_handler=None):
        self.db_handler = db_handler
    
    def create_order(self, order_data: Dict[str, Any]) -> Optional[int]:
        """Создание нового заказа"""
        try:
            if self.db_handler:
                return self.db_handler.save_order(order_data)
            
            # Для тестирования
            return 1
            
        except Exception as e:
            print(f"Ошибка создания заказа: {e}")
            return None
    
    def update_order(self, order_id: int, order_data: Dict[str, Any]) -> bool:
        """Обновление заказа"""
        try:
            if self.db_handler:
                return self.db_handler.update_order(order_id, order_data)
            return True
            
        except Exception as e:
            print(f"Ошибка обновления заказа: {e}")
            return False
    
    def delete_order(self, order_id: int) -> bool:
        """Удаление заказа"""
        try:
            if self.db_handler:
                return self.db_handler.delete_order(order_id)
            return True
            
        except Exception as e:
            print(f"Ошибка удаления заказа: {e}")
            return False
    
    def get_all_orders(self, include_items: bool = False) -> List[Dict]:
        """Получение всех заказов"""
        try:
            if self.db_handler:
                return self.db_handler.get_all_orders(include_items)
            
            # Тестовые данные
            return [
                {
                    'id': 1,
                    'order_number': 'EO-20231201-001',
                    'customer_name': 'ООО "Электросила"',
                    'status': 'В обработке',
                    'total_amount': 12500.50,
                    'created_at': '2023-12-01 10:30:00'
                },
                {
                    'id': 2,
                    'order_number': 'EO-20231201-002',
                    'customer_name': 'ИП Иванов',
                    'status': 'Новый',
                    'total_amount': 5670.00,
                    'created_at': '2023-12-01 11:45:00'
                }
            ]
            
        except Exception as e:
            print(f"Ошибка получения заказов: {e}")
            return []
    
    def get_order_details(self, order_id: int) -> Dict[str, Any]:
        """Получение деталей заказа"""
        try:
            if self.db_handler:
                return self.db_handler.get_order_details(order_id)
            
            # Тестовые данные
            return {
                'id': order_id,
                'order_number': f'EO-20231201-{order_id:03d}',
                'customer_name': 'Тестовый клиент',
                'customer_email': 'test@example.com',
                'customer_phone': '+7 (999) 123-45-67',
                'status': 'Новый',
                'total_amount': 10000.00,
                'notes': 'Тестовый заказ',
                'created_at': '2023-12-01 10:00:00',
                'items': [
                    {'product_id': 1, 'name': 'Кабель ВВГнг-LS', 'quantity': 100, 'price': 45.80, 'total': 4580.00},
                    {'product_id': 2, 'name': 'Автоматический выключатель', 'quantity': 10, 'price': 320.50, 'total': 3205.00}
                ]
            }
            
        except Exception as e:
            print(f"Ошибка получения деталей заказа: {e}")
            return {}
    
    def get_all_products(self) -> List[Dict]:
        """Получение всех продуктов"""
        try:
            if self.db_handler:
                return self.db_handler.get_all_products()
            
            # Тестовые данные
            return [
                {
                    'id': 1,
                    'name': 'Кабель ВВГнг-LS 3x1.5',
                    'category': 'Кабели',
                    'price': 45.80,
                    'quantity': 1000,
                    'specifications': {'сечение': '1.5 мм²', 'жилы': 3, 'цвет': 'серый'}
                },
                {
                    'id': 2,
                    'name': 'Автоматический выключатель 16А',
                    'category': 'Автоматы',
                    'price': 320.50,
                    'quantity': 200,
                    'specifications': {'номинал': '16А', 'полюса': 1, 'бренд': 'IEK'}
                },
                {
                    'id': 3,
                    'name': 'Щиток распределительный',
                    'category': 'Щитки',
                    'price': 1250.00,
                    'quantity': 50,
                    'specifications': {'материал': 'пластик', 'модулей': 24}
                }
            ]
            
        except Exception as e:
            print(f"Ошибка получения продуктов: {e}")
            return []
    
    def get_categories(self) -> List[str]:
        """Получение списка категорий"""
        try:
            products = self.get_all_products()
            categories = set(p['category'] for p in products)
            return sorted(list(categories))
        except Exception as e:
            print(f"Ошибка получения категорий: {e}")
            return ['Кабели', 'Автоматы', 'Щитки', 'Розетки', 'Освещение']
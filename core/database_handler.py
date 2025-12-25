"""
Обработчик базы данных SQLite
"""
import sqlite3
import json
from pathlib import Path
from typing import List, Dict, Any, Optional

class DatabaseHandler:
    """Класс для работы с базой данных SQLite"""
    
    def __init__(self, db_path: str = "database/orders.db"):
        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(exist_ok=True)
    
    def get_connection(self):
        """Получение соединения с БД"""
        conn = sqlite3.connect(str(self.db_path))
        conn.row_factory = sqlite3.Row
        return conn
    
    def save_order(self, order_data: Dict[str, Any]) -> Optional[int]:
        """Сохранение заказа в БД"""
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            # Генерируем номер заказа
            from datetime import datetime
            date_str = datetime.now().strftime("%Y%m%d")
            cursor.execute("SELECT COUNT(*) FROM orders WHERE order_number LIKE ?", (f"{date_str}-%",))
            count = cursor.fetchone()[0]
            order_number = f"{date_str}-{count + 1:03d}"
            
            # Сохраняем заказ
            cursor.execute('''
            INSERT INTO orders (order_number, customer_name, customer_email, 
                               customer_phone, status, total_amount, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                order_number,
                order_data.get('customer_name'),
                order_data.get('customer_email'),
                order_data.get('customer_phone'),
                order_data.get('status', 'Новый'),
                order_data.get('total_amount', 0),
                order_data.get('notes', '')
            ))
            
            order_id = cursor.lastrowid
            
            # Сохраняем позиции заказа
            for item in order_data.get('items', []):
                # Получаем имя продукта
                cursor.execute('SELECT name FROM products WHERE id = ?', (item.get('product_id'),))
                product_row = cursor.fetchone()
                product_name = product_row['name'] if product_row else 'Неизвестный продукт'
                
                cursor.execute('''
                INSERT INTO order_items (order_id, product_id, product_name, 
                                       quantity, price, total_price)
                VALUES (?, ?, ?, ?, ?, ?)
                ''', (
                    order_id,
                    item.get('product_id'),
                    product_name,
                    item.get('quantity', 0),
                    item.get('price', 0),
                    item.get('quantity', 0) * item.get('price', 0)
                ))
            
            conn.commit()
            conn.close()
            
            return order_id
            
        except Exception as e:
            print(f"Ошибка сохранения заказа: {e}")
            return None
    
    def get_all_orders(self, include_items: bool = False) -> List[Dict]:
        """Получение всех заказов"""
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            cursor.execute('''
            SELECT id, order_number, customer_name, customer_email, 
                   customer_phone, status, total_amount, notes,
                   strftime('%Y-%m-%d %H:%M:%S', created_at) as created_at
            FROM orders
            ORDER BY created_at DESC
            ''')
            
            orders = [dict(row) for row in cursor.fetchall()]
            
            if include_items:
                for order in orders:
                    order['items'] = self.get_order_items(order['id'])
            
            conn.close()
            return orders
            
        except Exception as e:
            print(f"Ошибка получения заказов: {e}")
            return []
    
    def get_order_items(self, order_id: int) -> List[Dict]:
        """Получение позиций заказа"""
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            cursor.execute('''
            SELECT product_id, product_name, quantity, price, total_price
            FROM order_items
            WHERE order_id = ?
            ''', (order_id,))
            
            items = [dict(row) for row in cursor.fetchall()]
            conn.close()
            return items
            
        except Exception as e:
            print(f"Ошибка получения позиций заказа: {e}")
            return []
    
    def get_all_products(self) -> List[Dict]:
        """Получение всех продуктов"""
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            cursor.execute('''
            SELECT id, name, category, price, quantity, specifications,
                   image_path, 
                   strftime('%Y-%m-%d %H:%M:%S', created_at) as created_at
            FROM products
            ORDER BY name
            ''')
            
            products = []
            for row in cursor.fetchall():
                product = dict(row)
                # Парсим спецификации из JSON
                if product.get('specifications'):
                    try:
                        product['specifications'] = json.loads(product['specifications'])
                    except:
                        product['specifications'] = {}
                else:
                    product['specifications'] = {}
                
                products.append(product)
            
            conn.close()
            return products
            
        except Exception as e:
            print(f"Ошибка получения продуктов: {e}")
            return []
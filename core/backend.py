"""
Основной класс для взаимодействия между QML и Python
"""
import json
import os
from .api_client import ApiClient

from datetime import datetime
from typing import List, Dict, Any

from PySide6.QtCore import QObject, Signal, Property, Slot

from .order_manager import OrderManager
from .database_handler import DatabaseHandler

class Backend(QObject):
    """Бэкенд для взаимодействия с QML интерфейсом"""
    
    # Сигналы для QML
    orderCreated = Signal(str)
    orderUpdated = Signal(str)
    orderDeleted = Signal(str)
    dataLoaded = Signal()
    errorOccurred = Signal(str)
    
    def __init__(self, order_manager: OrderManager = None):
        super().__init__()
        self._order_manager = order_manager or OrderManager()
        self._products = []
        self._orders = []
        self._categories = []
        
        # Загружаем начальные данные
        self.load_initial_data()
    
    def load_initial_data(self):
        """Загрузка начальных данных"""
        try:
            self._products = self._order_manager.get_all_products()
            self._orders = self._order_manager.get_all_orders()
            self._categories = self._order_manager.get_categories()
            self.dataLoaded.emit()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка загрузки данных: {str(e)}")
    
    # Свойства для QML
    @Property(list, constant=True)
    def categories(self):
        return self._categories
    
    @Property(list, notify=dataLoaded)
    def products(self):
        return self._products
    
    @Property(list, notify=dataLoaded)
    def orders(self):
        return self._orders
    
    @Slot(result=list)
    def getProducts(self):
        """Получение списка продуктов"""
        return self._products
    
    @Slot(result=list)
    def getOrders(self):
        """Получение списка заказов"""
        return self._orders
    
    @Slot(result=list)
    def getCategories(self):
        """Получение списка категорий"""
        return self._categories
    
    @Slot(str, result=list)
    def getProductsByCategory(self, category):
        """Получение продуктов по категории"""
        return [p for p in self._products if p.get('category') == category]
    
    @Slot(str, str, str, str, list, result=bool)
    def createOrder(self, customer_name, email, phone, notes, items):
        """Создание нового заказа"""
        try:
            order_data = {
                'customer_name': customer_name,
                'customer_email': email,
                'customer_phone': phone,
                'notes': notes,
                'items': items
            }
            
            order_id = self._order_manager.create_order(order_data)
            
            if order_id:
                self.orderCreated.emit(str(order_id))
                self._orders = self._order_manager.get_all_orders()
                self.dataLoaded.emit()
                return True
            return False
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка создания заказа: {str(e)}")
            return False
    
    @Slot(int, dict, result=bool)
    def updateOrder(self, order_id, order_data):
        """Обновление заказа"""
        try:
            success = self._order_manager.update_order(order_id, order_data)
            if success:
                self.orderUpdated.emit(str(order_id))
                self._orders = self._order_manager.get_all_orders()
                self.dataLoaded.emit()
            return success
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка обновления заказа: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def deleteOrder(self, order_id):
        """Удаление заказа"""
        try:
            success = self._order_manager.delete_order(order_id)
            if success:
                self.orderDeleted.emit(str(order_id))
                self._orders = self._order_manager.get_all_orders()
                self.dataLoaded.emit()
            return success
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка удаления заказа: {str(e)}")
            return False
    
    @Slot(int, result=dict)
    def getOrderDetails(self, order_id):
        """Получение деталей заказа"""
        try:
            return self._order_manager.get_order_details(order_id)
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка получения деталей заказа: {str(e)}")
            return {}
    
    @Slot(result=str)
    def generateOrderNumber(self):
        """Генерация номера заказа"""
        from datetime import datetime
        date_str = datetime.now().strftime("%Y%m%d")
        orders_today = len([o for o in self._orders if o.get('order_number', '').startswith(date_str)])
        return f"{date_str}-{orders_today + 1:03d}"
    
    @Slot(str, result=list)
    def searchProducts(self, query):
        """Поиск продуктов"""
        if not query:
            return self._products
        
        query_lower = query.lower()
        return [
            p for p in self._products
            if query_lower in p.get('name', '').lower() or 
               query_lower in p.get('category', '').lower() or
               query_lower in str(p.get('specifications', '')).lower()
        ]
    

    @Slot(result=dict)
    def getCurrencyRates(self):
        """
        HTTP-запрос курсов валют
        """
        rates = ApiClient.get_currency_rates()
        if rates is None:
            return {}
        return rates

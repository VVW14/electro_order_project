#!/usr/bin/env python3
"""
Главный файл приложения для формирования заказов электротехнического производства
"""
import sys
import os
import sqlite3
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

from core.backend import Backend
from core.database_handler import DatabaseHandler
from core.order_manager import OrderManager

def setup_database():
    """Инициализация базы данных"""
    db_path = Path("database") / "orders.db"
    db_path.parent.mkdir(exist_ok=True)
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Создаем таблицы
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER DEFAULT 0,
        specifications TEXT,
        image_path TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''')
    
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT UNIQUE NOT NULL,
        customer_name TEXT NOT NULL,
        customer_email TEXT,
        customer_phone TEXT,
        status TEXT DEFAULT 'Новый',
        total_amount REAL DEFAULT 0,
        notes TEXT DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''')
    
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
    )
    ''')
    
    # Добавляем тестовые данные (только если таблица пустая)
    cursor.execute('SELECT COUNT(*) FROM products')
    if cursor.fetchone()[0] == 0:
        products = [
            ('Кабель ВВГнг-LS 3x1.5', 'Кабели', 45.80, 1000, '{"сечение": "1.5 мм²", "жилы": 3, "цвет": "серый"}', ''),
            ('Автоматический выключатель 16А', 'Автоматы', 320.50, 200, '{"номинал": "16А", "полюса": 1, "бренд": "IEK"}', ''),
            ('Щиток распределительный', 'Щитки', 1250.00, 50, '{"материал": "пластик", "модулей": 24}', ''),
            ('Розетка Schuko', 'Розетки', 85.30, 500, '{"тип": "евро", "цвет": "белый", "IP": "20"}', ''),
            ('Светильник LED', 'Освещение', 450.00, 150, '{"мощность": "36W", "цвет": "теплый", "IP": "44"}', ''),
            ('Трансформатор 220/12В', 'Трансформаторы', 1200.00, 30, '{"мощность": "100VA", "напряжение": "220/12V"}', ''),
            ('Датчик движения', 'Датчики', 670.00, 80, '{"радиус": "10м", "угол": "180°", "IP": "54"}', ''),
            ('Реле времени', 'Реле', 890.00, 60, '{"диапазон": "0.1с-100ч", "контакты": "2СО"}', '')
        ]
        
        cursor.executemany('''
        INSERT INTO products (name, category, price, quantity, specifications, image_path)
        VALUES (?, ?, ?, ?, ?, ?)
        ''', products)
    
    conn.commit()
    conn.close()
    
    return str(db_path)

def main():
    """Главная функция приложения"""
    # Настройка пути для библиотек Qt
    os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Material'
    
    # Инициализация базы данных
    db_path = setup_database()
    
    # Создание приложения
    app = QGuiApplication(sys.argv)
    app.setApplicationName("ElectroOrder Manager")
    app.setOrganizationName("ElectroTech")
    
    # Создание движка QML
    engine = QQmlApplicationEngine()
    
    # Создание бэкенда
    db_handler = DatabaseHandler(db_path)
    order_manager = OrderManager(db_handler)
    backend = Backend(order_manager)
    
    # Регистрация бэкенда в QML контексте
    engine.rootContext().setContextProperty("backend", backend)
    
    # Загрузка главного QML файла
    qml_file = Path(__file__).parent / "ui" / "main.qml"
    
    if not qml_file.exists():
        print(f"Ошибка: файл {qml_file} не найден")
        sys.exit(-1)
    
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    
    if not engine.rootObjects():
        print("Ошибка загрузки QML интерфейса")
        sys.exit(-1)
    
    # Запуск приложения
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
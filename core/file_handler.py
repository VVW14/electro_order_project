"""
Обработчик файлов для экспорта/импорта данных
"""
import json
import csv
import pickle
from pathlib import Path
from typing import Dict, List, Any
from datetime import datetime

class FileHandler:
    """Класс для работы с файлами"""
    
    @staticmethod
    def save_json(filepath: str, data: Any) -> bool:
        """Сохранение данных в JSON файл"""
        try:
            path = Path(filepath)
            path.parent.mkdir(exist_ok=True)
            
            with open(path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2, default=str)
            
            return True
            
        except Exception as e:
            print(f"Ошибка сохранения JSON: {e}")
            return False
    
    @staticmethod
    def load_json(filepath: str) -> Any:
        """Загрузка данных из JSON файла"""
        try:
            path = Path(filepath)
            if not path.exists():
                return None
            
            with open(path, 'r', encoding='utf-8') as f:
                return json.load(f)
            
        except Exception as e:
            print(f"Ошибка загрузки JSON: {e}")
            return None
    
    @staticmethod
    def save_csv(filepath: str, data: List[Dict], headers: List[str] = None) -> bool:
        """Сохранение данных в CSV файл"""
        try:
            path = Path(filepath)
            path.parent.mkdir(exist_ok=True)
            
            if not data:
                return False
            
            if headers is None:
                headers = list(data[0].keys())
            
            with open(path, 'w', newline='', encoding='utf-8') as f:
                writer = csv.DictWriter(f, fieldnames=headers)
                writer.writeheader()
                writer.writerows(data)
            
            return True
            
        except Exception as e:
            print(f"Ошибка сохранения CSV: {e}")
            return False
    
    @staticmethod
    def export_order_to_pdf(order_data: Dict, filepath: str) -> bool:
        """Экспорт заказа в PDF (заглушка для реализации)"""
        try:
            # Здесь можно реализовать генерацию PDF с помощью ReportLab или другой библиотеки
            print(f"Экспорт заказа {order_data.get('order_number')} в PDF: {filepath}")
            return True
            
        except Exception as e:
            print(f"Ошибка экспорта в PDF: {e}")
            return False
    
    @staticmethod
    def backup_database(source_db: str, backup_dir: str = "backups") -> bool:
        """Создание резервной копии базы данных"""
        try:
            source = Path(source_db)
            if not source.exists():
                return False
            
            backup_dir_path = Path(backup_dir)
            backup_dir_path.mkdir(exist_ok=True)
            
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_path = backup_dir_path / f"orders_backup_{timestamp}.db"
            
            # Копирование файла базы данных
            import shutil
            shutil.copy2(source, backup_path)
            
            # Сохраняем информацию о бекапе
            backup_info = {
                'timestamp': timestamp,
                'source': str(source),
                'backup_path': str(backup_path),
                'size': backup_path.stat().st_size
            }
            
            info_path = backup_dir_path / f"backup_info_{timestamp}.json"
            FileHandler.save_json(str(info_path), backup_info)
            
            return True
            
        except Exception as e:
            print(f"Ошибка создания резервной копии: {e}")
            return False
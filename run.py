#!/usr/bin/env python3
"""
Скрипт для запуска приложения
"""
import sys
import os
from pathlib import Path

# Добавляем текущую директорию в путь Python
sys.path.insert(0, str(Path(__file__).parent))

from main import main

if __name__ == "__main__":
    # Проверяем наличие необходимых файлов
    required_files = [
        "ui/main.qml",
        "core/backend.py",
        "core/order_manager.py"
    ]
    
    missing_files = []
    for file in required_files:
        if not (Path(__file__).parent / file).exists():
            missing_files.append(file)
    
    if missing_files:
        print("Ошибка: отсутствуют необходимые файлы:")
        for file in missing_files:
            print(f"  - {file}")
        print("\nУбедитесь, что вы запускаете скрипт из корневой директории проекта.")
        sys.exit(1)
    
    # Запускаем приложение
    main()
#!/bin/bash
cd /mnt/c/Users/weiss/electro_order_project

# Проверяем, активировано ли виртуальное окружение
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Активация виртуального окружения..."
    source venv/bin/activate
else
    echo "Виртуальное окружение уже активировано"
fi

# Запуск приложения
python main.py

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "./components"  // Импорт компонентов из папки components

ApplicationWindow {
    width: 1200
    height: 800
    visible: true
    title: "Система формирования заказов - Электротехническое производство"

    property int currentPageIndex: 0
    
    // Простая навигация
    TabBar {
        id: tabBar
        width: parent.width
        
        TabButton {
            text: "Главная"
            onClicked: stackLayout.currentIndex = 0
        }
        TabButton {
            text: "Каталог"
            onClicked: stackLayout.currentIndex = 1
        }
        TabButton {
            text: "Новый заказ"
            onClicked: stackLayout.currentIndex = 2
        }
        TabButton {
            text: "Список заказов"
            onClicked: stackLayout.currentIndex = 3
        }
        TabButton {
            text: "Статистика"
            onClicked: stackLayout.currentIndex = 4
        }
        TabButton {
            text: "Настройки"
            onClicked: stackLayout.currentIndex = 5
        }
    }

    // Основной контент
    StackLayout {
        id: stackLayout
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        currentIndex: 0

        // Главная страница (Загрузка вашего существующего HomePage.qml)
        Page {
            Loader {
                anchors.fill: parent
                source: "pages/HomePage.qml"
            }
        }

        // Каталог продукции
        Page {
            ScrollView {
                anchors.fill: parent
                anchors.margins: 10
                
                GridLayout {
                    width: parent.width
                    columns: 3
                    
                    Repeater {
                        model: backend.products
                        
                        Rectangle {
                            width: 250
                            height: 150
                            border.color: "gray"
                            border.width: 1
                            radius: 5
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                
                                Text {
                                    text: modelData.name || ""
                                    font.bold: true
                                    font.pixelSize: 14
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Категория: " + (modelData.category || "")
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Цена: " + (modelData.price ? modelData.price.toFixed(2) + " ₽" : "")
                                    font.bold: true
                                    font.pixelSize: 13
                                    color: "green"
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "В наличии: " + (modelData.quantity || 0)
                                    font.pixelSize: 12
                                    color: "blue"
                                    Layout.fillWidth: true
                                }
                                
                                Button {
                                    text: "Добавить в заказ"
                                    onClicked: {
                                        // Переключаемся на страницу создания заказа
                                        stackLayout.currentIndex = 2
                                        console.log("Добавление продукта:", modelData.name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

// Создание заказа (полная форма с выбором товаров)
Page {
    id: orderFormPage
    padding: 15
    
    // Данные формы
    property string customerName: ""
    property string customerEmail: ""
    property string customerPhone: ""
    property string orderNotes: ""
    property double orderTotal: 0
    
    // Модели
    ListModel {
        id: availableProductsModel
    }
    
    ListModel {
        id: selectedProductsModel
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 15
        
        // Левая колонка - информация о клиенте и выбранные товары
        ColumnLayout {
            Layout.preferredWidth: 350
            Layout.fillHeight: true
            spacing: 15
            
            // Карточка информации о клиенте
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                radius: 8
                border.color: "gray"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    Text {
                        text: "Информация о клиенте"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    // Поля формы
                    TextField {
                        id: nameField
                        Layout.fillWidth: true
                        placeholderText: "ФИО или название организации *"
                        
                        onTextChanged: orderFormPage.customerName = text
                    }
                    
                    TextField {
                        id: emailField
                        Layout.fillWidth: true
                        placeholderText: "Email"
                        inputMethodHints: Qt.ImhEmailCharactersOnly
                        
                        onTextChanged: orderFormPage.customerEmail = text
                    }
                    
                    TextField {
                        id: phoneField
                        Layout.fillWidth: true
                        placeholderText: "Телефон *"
                        inputMethodHints: Qt.ImhDialableCharactersOnly
                        
                        onTextChanged: orderFormPage.customerPhone = text
                    }
                    
                    TextArea {
                        id: notesField
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        placeholderText: "Примечания к заказу"
                        wrapMode: Text.WordWrap
                        
                        onTextChanged: orderFormPage.orderNotes = text
                    }
                }
            }
            
            // Выбранные продукты
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                radius: 8
                border.color: "gray"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5
                    
                    Text {
                        text: "Выбранные товары (" + selectedProductsModel.count + ")"
                        font.bold: true
                        font.pixelSize: 14
                    }
                    
                    ListView {
                        id: selectedProductsList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: selectedProductsModel
                        
                        delegate: Rectangle {
                            width: selectedProductsList.width
                            height: 50
                            color: index % 2 === 0 ? "#f5f5f5" : "white"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 10
                                
                                Text {
                                    text: name || ""
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                
                                SpinBox {
                                    id: quantitySpin
                                    from: 1
                                    to: maxQuantity
                                    value: selectedQuantity
                                    Layout.preferredWidth: 80
                                    
                                    onValueChanged: {
                                        orderFormPage.updateProductQuantity(index, value)
                                    }
                                }
                                
                                Text {
                                    text: (price * selectedQuantity).toFixed(2) + " ₽"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                                
                                Button {
                                    text: "✕"
                                    flat: true
                                    onClicked: orderFormPage.removeProductFromOrder(index)
                                }
                            }
                        }
                    }
                }
            }
            
            // Итоговая сумма
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                radius: 8
                color: "#e8f5e9"
                border.color: "#4caf50"
                border.width: 2
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    
                    Text {
                        text: "Итоговая сумма"
                        font.pixelSize: 14
                        color: "#388e3c"
                    }
                    
                    Text {
                        id: totalText
                        text: orderFormPage.orderTotal.toFixed(2) + " ₽"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#1b5e20"
                    }
                }
            }
        }
        
        // Правая колонка - каталог продукции
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            
            // Панель поиска и фильтрации
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Поиск продукции..."
                    onTextChanged: orderFormPage.filterProducts()
                }
                
                ComboBox {
                    id: categoryFilter
                    Layout.preferredWidth: 200
                    model: ["Все категории"].concat(backend.categories)
                    onCurrentTextChanged: orderFormPage.filterProducts()
                }
            }
            
            // Список доступной продукции
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                GridView {
                    id: productsGrid
                    width: parent.width
                    cellWidth: 280
                    cellHeight: 200
                    clip: true
                    
                    model: availableProductsModel
                    
                    delegate: ProductCard {
                        width: productsGrid.cellWidth - 10
                        height: productsGrid.cellHeight - 10
                        productData: modelData
                        onAddToCart: function(product) {
                            orderFormPage.addProductToOrder(product)
                        }
                    }
                }
            }
        }
    }
    
    // Кнопки действий
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10
        
        Item { Layout.fillWidth: true } // Распорка
        
        Button {
            text: "Очистить"
            onClicked: orderFormPage.clearForm()
        }
        
        Button {
            text: "Создать заказ"
            enabled: orderFormPage.customerName && orderFormPage.customerPhone && selectedProductsModel.count > 0
            onClicked: orderFormPage.createOrder()
        }
    }
    
    // Функции JavaScript
    function filterProducts() {
        console.log("Фильтрация продуктов...")
        availableProductsModel.clear()
        var allProducts = backend.getProducts()
        
        for (var i = 0; i < allProducts.length; i++) {
            var product = allProducts[i]
            var matchesSearch = !searchField.text || 
                               product.name.toLowerCase().includes(searchField.text.toLowerCase())
            
            var matchesCategory = !categoryFilter.currentText || 
                                 categoryFilter.currentText === "Все категории" ||
                                 product.category === categoryFilter.currentText
            
            if (matchesSearch && matchesCategory) {
                availableProductsModel.append({modelData: product})
            }
        }
    }
    
    function addProductToOrder(product) {
        console.log("Добавление продукта в заказ:", product.name)
        
        // Проверяем, не добавлен ли уже продукт
        for (var i = 0; i < selectedProductsModel.count; i++) {
            var item = selectedProductsModel.get(i)
            if (item.id === product.id) {
                // Увеличиваем количество
                selectedProductsModel.setProperty(i, "selectedQuantity", item.selectedQuantity + 1)
                calculateTotal()
                return
            }
        }
        
        // Добавляем новый продукт
        selectedProductsModel.append({
            id: product.id,
            name: product.name,
            price: product.price,
            maxQuantity: product.quantity,
            selectedQuantity: 1
        })
        
        calculateTotal()
    }
    
    function removeProductFromOrder(index) {
        console.log("Удаление продукта из заказа:", index)
        selectedProductsModel.remove(index)
        calculateTotal()
    }
    
    function updateProductQuantity(index, quantity) {
        console.log("Обновление количества:", index, quantity)
        selectedProductsModel.setProperty(index, "selectedQuantity", quantity)
        calculateTotal()
    }
    
    function calculateTotal() {
        var total = 0
        for (var i = 0; i < selectedProductsModel.count; i++) {
            var item = selectedProductsModel.get(i)
            total += item.price * item.selectedQuantity
        }
        orderTotal = total
        totalText.text = orderTotal.toFixed(2) + " ₽"
        console.log("Итоговая сумма:", orderTotal)
    }
    
    function clearForm() {
        console.log("Очистка формы")
        customerName = ""
        customerEmail = ""
        customerPhone = ""
        orderNotes = ""
        orderTotal = 0
        
        nameField.text = ""
        emailField.text = ""
        phoneField.text = ""
        notesField.text = ""
        searchField.text = ""
        categoryFilter.currentIndex = 0
        
        selectedProductsModel.clear()
        totalText.text = "0.00 ₽"
        
        filterProducts()
    }
    
    function createOrder() {
        console.log("Создание заказа...")
        
        // Собираем данные о товарах
        var orderItems = []
        for (var i = 0; i < selectedProductsModel.count; i++) {
            var item = selectedProductsModel.get(i)
            orderItems.push({
                product_id: item.id,
                quantity: item.selectedQuantity,
                price: item.price
            })
        }
        
        console.log("Данные заказа:", {
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            orderNotes: orderNotes,
            items: orderItems
        })
        
        var success = backend.createOrder(customerName, customerEmail, customerPhone, orderNotes, orderItems)
        if (success) {
            console.log("Заказ успешно создан!")
            clearForm()
            // Переключаемся на вкладку списка заказов
            stackLayout.currentIndex = 3
        } else {
            console.log("Ошибка при создании заказа")
        }
    }
    
    // Инициализация
    Component.onCompleted: {
        console.log("Инициализация страницы создания заказа")
        filterProducts()
    }
}

        // Список заказов
        Page {
            ListView {
                anchors.fill: parent
                anchors.margins: 10
                model: backend.orders
                
                delegate: Rectangle {
                    width: parent.width
                    height: 70
                    border.color: "gray"
                    border.width: 1
                    radius: 5
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        Text {
                            text: "Заказ #" + (modelData.order_number || "")
                            font.bold: true
                            font.pixelSize: 16
                        }
                        
                        Text {
                            text: "Клиент: " + (modelData.customer_name || "")
                            font.pixelSize: 14
                        }
                        
                        Text {
                            text: "Сумма: " + (modelData.total_amount ? modelData.total_amount.toFixed(2) + " ₽" : "")
                            font.pixelSize: 14
                            color: "green"
                        }
                    }
                }
            }
        }

        // Статистика
        Page {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "Статистика"
                    font.pixelSize: 24
                    font.bold: true
                }
                
                Text {
                    text: "Общее количество заказов: " + (backend.orders ? backend.orders.length : 0)
                    font.pixelSize: 18
                }
            }
        }

        // Настройки
        Page {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "Настройки"
                    font.pixelSize: 24
                    font.bold: true
                }
                
                Text {
                    text: "Здесь будут настройки приложения"
                    font.pixelSize: 18
                }
            }
        }
    }
}
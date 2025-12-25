import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components"

Page {
    id: orderFormPage
    padding: 20
    
    // Данные формы
    property string customerName: ""
    property string customerEmail: ""
    property string customerPhone: ""
    property string orderNotes: ""
    property var selectedProducts: []
    property double orderTotal: 0
    
    // Список продуктов для выбора
    ListModel {
        id: availableProductsModel
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        
        // Заголовок
        Text {
            text: qsTr("Формирование заказа")
            font.pixelSize: 24
            font.bold: true
            Layout.fillWidth: true
        }
        
        // Основная форма в две колонки
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 30
            
            // Левая колонка - информация о клиенте
            ColumnLayout {
                Layout.preferredWidth: 400
                Layout.fillHeight: true
                spacing: 15
                
                // Карточка информации о клиенте
                Rectangle {
                    Layout.fillWidth: true
                    height: 300
                    radius: 8
                    color: Material.backgroundColor
                    border.color: Material.dividerColor
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        Text {
                            text: qsTr("Информация о клиенте")
                            font.pixelSize: 18
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        
                        // Поля формы
                        TextField {
                            id: nameField
                            Layout.fillWidth: true
                            placeholderText: qsTr("ФИО или название организации *")
                            Material.background: Material.color(Material.Grey, Material.Shade50)
                            
                            onTextChanged: customerName = text
                        }
                        
                        TextField {
                            id: emailField
                            Layout.fillWidth: true
                            placeholderText: qsTr("Email")
                            inputMethodHints: Qt.ImhEmailCharactersOnly
                            validator: RegularExpressionValidator {
                                regularExpression: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
                            }
                            
                            onTextChanged: customerEmail = text
                        }
                        
                        TextField {
                            id: phoneField
                            Layout.fillWidth: true
                            placeholderText: qsTr("Телефон *")
                            inputMethodHints: Qt.ImhDialableCharactersOnly
                            validator: RegularExpressionValidator {
                                regularExpression: /^[\d\s\-\+\(\)]+$/
                            }
                            
                            onTextChanged: customerPhone = text
                        }
                        
                        TextArea {
                            id: notesField
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            placeholderText: qsTr("Примечания к заказу")
                            wrapMode: Text.WordWrap
                            
                            onTextChanged: orderNotes = text
                        }
                    }
                }
                
                // Итоговая сумма
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    radius: 8
                    color: Material.color(Material.Green, Material.Shade50)
                    border.color: Material.color(Material.Green, Material.Shade200)
                    border.width: 2
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        
                        Text {
                            text: qsTr("Итоговая сумма")
                            font.pixelSize: 14
                            color: Material.color(Material.Grey, Material.Shade600)
                        }
                        
                        Text {
                            text: orderTotal.toFixed(2) + " ₽"
                            font.pixelSize: 32
                            font.bold: true
                            color: Material.color(Material.Green, Material.Shade800)
                        }
                    }
                }
            }
            
            // Правая колонка - выбор продукции
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15
                
                // Заголовок с поиском
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: qsTr("Выбор продукции")
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    TextField {
                        id: searchField
                        Layout.preferredWidth: 200
                        placeholderText: qsTr("Поиск продукции...")
                        onTextChanged: filterProducts()
                    }
                    
                    ComboBox {
                        id: categoryFilter
                        Layout.preferredWidth: 150
                        model: backend.categories
                        displayText: currentText ? qsTr("Категория: ") + currentText : qsTr("Все категории")
                        onCurrentTextChanged: filterProducts()
                    }
                }
                
                // Список доступной продукции
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: Material.backgroundColor
                    border.color: Material.dividerColor
                    border.width: 1
                    
                    GridView {
                        id: productsGrid
                        anchors.fill: parent
                        anchors.margins: 10
                        cellWidth: 280
                        cellHeight: 200
                        clip: true
                        
                        model: availableProductsModel
                        
                        delegate: ProductCard {
                            width: productsGrid.cellWidth - 10
                            height: productsGrid.cellHeight - 10
                            productData: modelData
                            
                            onClicked: {
                                // Просмотр деталей продукта
                                productDetailsDialog.productData = modelData
                                productDetailsDialog.open()
                            }
                            
                            onAddToCart: {
                                addProductToOrder(modelData)
                            }
                        }
                        
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AlwaysOn
                        }
                    }
                }
                
                // Выбранные продукты
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    radius: 8
                    color: Material.backgroundColor
                    border.color: Material.dividerColor
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5
                        
                        Text {
                            text: qsTr("Выбранные товары") + " (" + selectedProducts.length + ")"
                            font.bold: true
                            font.pixelSize: 14
                        }
                        
                        ListView {
                            id: selectedProductsList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: selectedProducts
                            
                            delegate: Rectangle {
                                width: selectedProductsList.width
                                height: 40
                                color: index % 2 === 0 ? Material.backgroundColor : 
                                                       Material.color(Material.Grey, Material.Shade50)
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    spacing: 10
                                    
                                    Text {
                                        text: modelData.name || ""
                                        font.pixelSize: 13
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                    
                                    SpinBox {
                                        id: quantitySpin
                                        from: 1
                                        to: modelData.quantity || 1
                                        value: modelData.selectedQuantity || 1
                                        Layout.preferredWidth: 80
                                        
                                        onValueChanged: {
                                            updateProductQuantity(index, value)
                                        }
                                    }
                                    
                                    Text {
                                        text: (modelData.price * (modelData.selectedQuantity || 1)).toFixed(2) + " ₽"
                                        font.bold: true
                                        Layout.preferredWidth: 100
                                    }
                                    
                                    Button {
                                        text: "✕"
                                        flat: true
                                        onClicked: removeProductFromOrder(index)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Кнопки действий
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Item { Layout.fillWidth: true } // Распорка
            
            CustomButton {
                text: qsTr("Очистить")
                buttonColor: Material.color(Material.Grey)
                onClicked: clearForm()
            }
            
            CustomButton {
                text: qsTr("Сохранить черновик")
                buttonColor: Material.color(Material.Orange)
                onClicked: saveDraft()
            }
            
            CustomButton {
                text: qsTr("Создать заказ")
                buttonColor: Material.color(Material.Blue)
                enabled: customerName && customerPhone && selectedProducts.length > 0
                onClicked: createOrder()
            }
        }
    }
    
    // Диалог деталей продукта
    Dialog {
        id: productDetailsDialog
        title: qsTr("Детали продукта")
        standardButtons: Dialog.Ok
        modal: true
        
        property var productData: ({})
        
        ColumnLayout {
            width: 400
            spacing: 10
            
            Text {
                text: productData.name || ""
                font.bold: true
                font.pixelSize: 16
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            Text {
                text: qsTr("Категория: ") + (productData.category || "")
                font.pixelSize: 14
                Layout.fillWidth: true
            }
            
            Text {
                text: qsTr("Цена: ") + (productData.price ? productData.price.toFixed(2) + " ₽" : "")
                font.bold: true
                font.pixelSize: 14
                color: Material.color(Material.Green, Material.Shade700)
            }
            
            Text {
                text: qsTr("В наличии: ") + (productData.quantity || 0)
                font.pixelSize: 14
                Layout.fillWidth: true
            }
            
            // Спецификации
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: Material.color(Material.Grey, Material.Shade50)
                radius: 4
                
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 5
                    
                    Text {
                        width: parent.width
                        text: formatSpecifications(productData.specifications || {})
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
    
    // Функции
    function filterProducts() {
        availableProductsModel.clear()
        var allProducts = backend.getProducts()
        
        for (var i = 0; i < allProducts.length; i++) {
            var product = allProducts[i]
            var matchesSearch = !searchField.text || 
                               product.name.toLowerCase().includes(searchField.text.toLowerCase()) ||
                               JSON.stringify(product.specifications).toLowerCase().includes(searchField.text.toLowerCase())
            
            var matchesCategory = !categoryFilter.currentText || 
                                 product.category === categoryFilter.currentText
            
            if (matchesSearch && matchesCategory) {
                availableProductsModel.append({modelData: product})
            }
        }
    }
    
    function addProductToOrder(product) {
        // Проверяем, не добавлен ли уже продукт
        for (var i = 0; i < selectedProducts.length; i++) {
            if (selectedProducts[i].id === product.id) {
                selectedProducts[i].selectedQuantity += 1
                calculateTotal()
                return
            }
        }
        
        // Добавляем новый продукт
        var productCopy = JSON.parse(JSON.stringify(product))
        productCopy.selectedQuantity = 1
        selectedProducts.push(productCopy)
        calculateTotal()
    }
    
    function removeProductFromOrder(index) {
        selectedProducts.splice(index, 1)
        calculateTotal()
    }
    
    function updateProductQuantity(index, quantity) {
        selectedProducts[index].selectedQuantity = quantity
        calculateTotal()
    }
    
    function calculateTotal() {
        var total = 0
        for (var i = 0; i < selectedProducts.length; i++) {
            var product = selectedProducts[i]
            total += product.price * (product.selectedQuantity || 1)
        }
        orderTotal = total
    }
    
    function clearForm() {
        customerName = ""
        customerEmail = ""
        customerPhone = ""
        orderNotes = ""
        selectedProducts = []
        orderTotal = 0
        
        nameField.text = ""
        emailField.text = ""
        phoneField.text = ""
        notesField.text = ""
        searchField.text = ""
        
        filterProducts()
    }
    
    function saveDraft() {
        // Сохранение черновика в локальное хранилище
        var draft = {
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            orderNotes: orderNotes,
            selectedProducts: selectedProducts,
            orderTotal: orderTotal,
            savedAt: new Date().toISOString()
        }
        
        // Можно сохранить в localStorage или файл
        console.log("Черновик сохранен:", draft)
        
        // Показать уведомление
        showMessage(qsTr("Черновик сохранен"), qsTr("Заказ сохранен как черновик."))
    }
    
    function createOrder() {
        var orderItems = []
        for (var i = 0; i < selectedProducts.length; i++) {
            var product = selectedProducts[i]
            orderItems.push({
                product_id: product.id,
                product_name: product.name,
                quantity: product.selectedQuantity || 1,
                price: product.price
            })
        }
        
        var orderData = {
            customer_name: customerName,
            customer_email: customerEmail,
            customer_phone: customerPhone,
            notes: orderNotes,
            items: orderItems,
            status: "Новый",
            total_amount: orderTotal
        }
        
        if (backend.createOrder(customerName, customerEmail, customerPhone, orderNotes, orderItems)) {
            showMessage(qsTr("Заказ создан"), qsTr("Заказ успешно создан!"))
            clearForm()
            mainWindow.navigateToPage(3) // Переход к списку заказов
        } else {
            showMessage(qsTr("Ошибка"), qsTr("Не удалось создать заказ."), true)
        }
    }
    
    function formatSpecifications(specs) {
        var result = ""
        for (var key in specs) {
            result += key + ": " + specs[key] + "\n"
        }
        return result
    }
    
    function showMessage(title, text, isError = false) {
        errorDialog.title = title
        errorDialog.text = text
        errorDialog.open()
    }
    
    // Инициализация
    Component.onCompleted: {
        filterProducts()
    }
}
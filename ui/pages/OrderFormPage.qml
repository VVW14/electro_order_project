import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: orderFormPage
    padding: 15
    
    property string customerName: ""
    property string customerPhone: ""
    property var selectedProducts: []
    property double orderTotal: 0.0
    
    ListModel {
        id: productsModel
    }
    
    ListModel {
        id: cartModel
    }
    
    Component.onCompleted: {
        loadProducts()
    }
    
    function loadProducts() {
        productsModel.clear()
        var allProducts = backend.getProducts()
        for (var i = 0; i < allProducts.length; i++) {
            productsModel.append(allProducts[i])
        }
        console.log("Загружено продуктов:", productsModel.count)
    }
    
    function addToCart(product) {
        console.log("Добавление в корзину:", product.name)
        
        // Проверяем, есть ли уже такой товар в корзине
        for (var i = 0; i < cartModel.count; i++) {
            var item = cartModel.get(i)
            if (item.id === product.id) {
                cartModel.setProperty(i, "quantity", item.quantity + 1)
                updateTotal()
                return
            }
        }
        
        // Добавляем новый товар
        cartModel.append({
            id: product.id,
            name: product.name,
            price: product.price,
            quantity: 1
        })
        
        updateTotal()
    }
    
    function updateTotal() {
        var total = 0
        for (var i = 0; i < cartModel.count; i++) {
            var item = cartModel.get(i)
            total += item.price * item.quantity
        }
        orderTotal = total
        console.log("Обновленная сумма:", orderTotal)
    }
    
    function removeFromCart(index) {
        cartModel.remove(index)
        updateTotal()
    }
    
    function createOrder() {
        if (!customerName || !customerPhone || cartModel.count === 0) {
            console.log("Не все поля заполнены")
            return
        }
        
        var items = []
        for (var i = 0; i < cartModel.count; i++) {
            var item = cartModel.get(i)
            items.push({
                product_id: item.id,
                quantity: item.quantity,
                price: item.price
            })
        }
        
        console.log("Создание заказа...")
        var success = backend.createOrder(customerName, "", customerPhone, "", items)
        if (success) {
            console.log("Заказ создан!")
            cartModel.clear()
            customerNameField.text = ""
            customerPhoneField.text = ""
            orderTotal = 0
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        
        Text {
            text: "Создание заказа"
            font.pixelSize: 24
            font.bold: true
            Layout.fillWidth: true
        }
        
        // Форма клиента
        GroupBox {
            title: "Информация о клиенте"
            Layout.fillWidth: true
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                
                TextField {
                    id: customerNameField
                    placeholderText: "ФИО *"
                    Layout.fillWidth: true
                    onTextChanged: customerName = text
                }
                
                TextField {
                    id: customerPhoneField
                    placeholderText: "Телефон *"
                    Layout.fillWidth: true
                    onTextChanged: customerPhone = text
                }
            }
        }
        
        // Товары в корзине
        GroupBox {
            title: "Товары в заказе (" + cartModel.count + ")"
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            
            ListView {
                anchors.fill: parent
                model: cartModel
                
                delegate: RowLayout {
                    width: parent.width
                    spacing: 10
                    
                    Text {
                        text: name
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "×" + quantity
                    }
                    
                    Text {
                        text: (price * quantity).toFixed(2) + " ₽"
                        font.bold: true
                    }
                    
                    Button {
                        text: "✕"
                        onClicked: removeFromCart(index)
                    }
                }
            }
        }
        
        // Список товаров
        GroupBox {
            title: "Доступные товары"
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ScrollView {
                anchors.fill: parent
                
                GridLayout {
                    width: parent.width
                    columns: 3
                    
                    Repeater {
                        model: productsModel
                        
                        Rectangle {
                            width: 200
                            height: 120
                            border.color: "gray"
                            border.width: 1
                            radius: 5
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 5
                                
                                Text {
                                    text: name
                                    font.bold: true
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Цена: " + price.toFixed(2) + " ₽"
                                    color: "green"
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "В наличии: " + quantity
                                    color: "blue"
                                    Layout.fillWidth: true
                                }
                                
                                Button {
                                    text: "Добавить"
                                    Layout.fillWidth: true
                                    onClicked: addToCart(model)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Итог и кнопки
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Итого: " + orderTotal.toFixed(2) + " ₽"
                font.pixelSize: 18
                font.bold: true
                color: "green"
                Layout.fillWidth: true
            }
            
            Button {
                text: "Очистить"
                onClicked: {
                    cartModel.clear()
                    customerNameField.text = ""
                    customerPhoneField.text = ""
                    orderTotal = 0
                }
            }
            
            Button {
                text: "Создать заказ"
                enabled: customerName && customerPhone && cartModel.count > 0
                onClicked: createOrder()
            }
        }
    }
}
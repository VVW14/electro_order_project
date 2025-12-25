import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {
    id: card
    width: 280
    height: 200
    radius: 8
    color: Material.backgroundColor
    border.color: Material.dividerColor
    border.width: 1
    
    property var productData: ({})
    
    // Функция обратного вызова вместо сигнала
    property var onAddToCart: null
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        
        // Заголовок с названием продукта
        Text {
            Layout.fillWidth: true
            text: productData.name || ""
            font.bold: true
            font.pixelSize: 14
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
        
        // Категория
        Text {
            Layout.fillWidth: true
            text: productData.category || ""
            font.pixelSize: 12
            color: "gray"
        }
        
        // Цена и количество
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "Цена: " + (productData.price ? productData.price.toFixed(2) + " ₽" : "")
                font.bold: true
                font.pixelSize: 13
                color: "green"
            }
            
            Text {
                text: "В наличии: " + (productData.quantity || 0)
                font.pixelSize: 12
                color: "blue"
                Layout.fillWidth: true
            }
        }
        
        // Кнопка добавления в заказ
        Button {
            id: addButton
            Layout.fillWidth: true
            text: "Добавить в заказ"
            enabled: productData.quantity > 0
            
            onClicked: {
                console.log("КНОПКА НАЖАТА: Добавление продукта", productData.name)
                console.log("productData:", JSON.stringify(productData))
                console.log("onAddToCart:", onAddToCart)
                
                if (onAddToCart && typeof onAddToCart === "function") {
                    console.log("Вызываю функцию onAddToCart...")
                    onAddToCart(productData)
                } else {
                    console.log("ОШИБКА: onAddToCart не является функцией или не определена")
                }
            }
        }
    }
    
    // Клик по карточке
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: console.log("Клик по карточке:", productData.name)
    }
}
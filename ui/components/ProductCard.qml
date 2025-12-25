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
    property bool selected: false
    
    // Свойство для передачи функции обратного вызова
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
            Layout.fillWidth: true
            text: "Добавить в заказ"
            enabled: productData.quantity > 0
            
            onClicked: {
                if (onAddToCart) {
                    onAddToCart(productData)
                    // Анимация добавления
                    addAnim.start()
                }
            }
        }
    }
    
    // Анимация добавления
    SequentialAnimation {
        id: addAnim
        PropertyAnimation {
            target: card
            property: "scale"
            to: 0.95
            duration: 100
        }
        PropertyAnimation {
            target: card
            property: "scale"
            to: 1.0
            duration: 100
        }
    }
    
    // Клик по карточке
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: console.log("Клик по продукту:", productData.name)
        hoverEnabled: true
        
        onEntered: {
            if (!selected) {
                card.border.color = "blue"
            }
        }
        
        onExited: {
            if (!selected) {
                card.border.color = Material.dividerColor
            }
        }
    }
}
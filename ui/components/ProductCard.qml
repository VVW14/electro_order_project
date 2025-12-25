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
    
    signal clicked()
    signal addToCart()
    
    // Эффект при выборе
    layer.enabled: selected
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 0
        radius: 8
        samples: 17
        color: Material.color(Material.Blue, Material.Shade200)
    }
    
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
            color: Material.foreground
        }
        
        // Категория
        Text {
            Layout.fillWidth: true
            text: productData.category || ""
            font.pixelSize: 12
            color: Material.color(Material.Grey)
        }
        
        // Спецификации
        Column {
            Layout.fillWidth: true
            spacing: 2
            visible: productData.specifications && Object.keys(productData.specifications).length > 0
            
            Repeater {
                model: productData.specifications ? Object.keys(productData.specifications) : []
                
                Text {
                    width: parent.width
                    text: modelData + ": " + productData.specifications[modelData]
                    font.pixelSize: 11
                    color: Material.color(Material.Grey, Material.Shade600)
                    elide: Text.ElideRight
                }
            }
        }
        
        // Цена и количество
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: qsTr("Цена:") + " " + (productData.price ? productData.price.toFixed(2) + " ₽" : "")
                font.bold: true
                font.pixelSize: 13
                color: Material.color(Material.Green, Material.Shade700)
            }
            
            Text {
                text: qsTr("В наличии:") + " " + (productData.quantity || 0)
                font.pixelSize: 12
                color: Material.color(Material.Blue, Material.Shade600)
                Layout.fillWidth: true
            }
        }
        
        // Кнопка добавления в заказ
        CustomButton {
            Layout.fillWidth: true
            text: qsTr("Добавить в заказ")
            buttonColor: Material.color(Material.Blue)
            iconSource: "➕"
            enabled: productData.quantity > 0
            
            onClicked: {
                card.addToCart()
                
                // Анимация добавления
                addAnim.start()
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
        onClicked: card.clicked()
        hoverEnabled: true
        
        onEntered: {
            if (!selected) {
                card.border.color = Material.color(Material.Blue, Material.Shade300)
            }
        }
        
        onExited: {
            if (!selected) {
                card.border.color = Material.dividerColor
            }
        }
    }
}
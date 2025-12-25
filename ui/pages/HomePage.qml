import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components"

Page {
    id: homePage
    padding: 20
    
    // Статистика
    property int totalOrders: backend.orders ? backend.orders.length : 0
    property int totalProducts: backend.products ? backend.products.length : 0
    property double totalRevenue: {
        var sum = 0
        if (backend.orders) {
            for (var i = 0; i < backend.orders.length; i++) {
                sum += backend.orders[i].total_amount || 0
            }
        }
        return sum
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        
        // Заголовок
        Text {
            text: qsTr("Добро пожаловать в систему формирования заказов")
            font.pixelSize: 24
            font.bold: true
            Layout.fillWidth: true
            color: Material.foreground
        }
        
        // Быстрые действия
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            
            CustomButton {
                text: qsTr("Новый заказ")
                iconSource: "➕"
                buttonColor: Material.color(Material.Blue)
                Layout.fillWidth: true
                onClicked: mainWindow.navigateToPage(2)
            }
            
            CustomButton {
                text: qsTr("Каталог")
                iconSource: "📦"
                buttonColor: Material.color(Material.Green)
                Layout.fillWidth: true
                onClicked: mainWindow.navigateToPage(1)
            }
            
            CustomButton {
                text: qsTr("Заказы")
                iconSource: "📋"
                buttonColor: Material.color(Material.Orange)
                Layout.fillWidth: true
                onClicked: mainWindow.navigateToPage(3)
            }
        }
        
        // Статистика
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 15
            rowSpacing: 15
            
            // Карточка заказов
            StatsCard {
                title: qsTr("Всего заказов")
                value: totalOrders
                icon: "📋"
                color: Material.color(Material.Blue)
                Layout.fillWidth: true
            }
            
            // Карточка продуктов
            StatsCard {
                title: qsTr("Продуктов в каталоге")
                value: totalProducts
                icon: "📦"
                color: Material.color(Material.Green)
                Layout.fillWidth: true
            }
            
            // Карточка выручки
            StatsCard {
                title: qsTr("Общая выручка")
                value: totalRevenue.toFixed(2) + " ₽"
                icon: "💰"
                color: Material.color(Material.Orange)
                Layout.fillWidth: true
            }
        }
        
        // Последние заказы
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: Material.backgroundColor
            border.color: Material.dividerColor
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                // Заголовок раздела
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: qsTr("Последние заказы")
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    CustomButton {
                        text: qsTr("Все заказы")
                        flat: true
                        onClicked: mainWindow.navigateToPage(3)
                    }
                }
                
                // Список заказов
                ListView {
                    id: recentOrdersList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: backend.orders ? backend.orders.slice(0, 5) : []
                    
                    delegate: Rectangle {
                        width: recentOrdersList.width
                        height: 60
                        color: index % 2 === 0 ? Material.backgroundColor : 
                                               Material.color(Material.Grey, Material.Shade50)
                        radius: 4
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 15
                            
                            // Номер заказа
                            Text {
                                text: modelData.order_number || ""
                                font.bold: true
                                font.pixelSize: 14
                                Layout.preferredWidth: 150
                            }
                            
                            // Клиент
                            Text {
                                text: modelData.customer_name || ""
                                font.pixelSize: 13
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            
                            // Статус
                            StatusBadge {
                                status: modelData.status || "Новый"
                                Layout.preferredWidth: 100
                            }
                            
                            // Сумма
                            Text {
                                text: (modelData.total_amount || 0).toFixed(2) + " ₽"
                                font.bold: true
                                font.pixelSize: 14
                                color: Material.color(Material.Green, Material.Shade700)
                            }
                            
                            // Дата
                            Text {
                                text: modelData.created_at ? 
                                      new Date(modelData.created_at).toLocaleDateString(Qt.locale(), "dd.MM.yyyy") : ""
                                font.pixelSize: 12
                                color: Material.color(Material.Grey)
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Можно добавить просмотр деталей заказа
                                console.log("Просмотр заказа:", modelData.id)
                            }
                        }
                    }
                    
                    // Заглушка если нет заказов
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Нет заказов")
                        visible: recentOrdersList.count === 0
                        font.italic: true
                        color: Material.color(Material.Grey)
                    }
                }
            }
        }
    }
    
    // Компонент для отображения статистики
    component StatsCard: Rectangle {
        property string title: ""
        property var value: 0
        property string icon: ""
        property color color: Material.primary
        
        height: 120
        radius: 8
        color: Material.backgroundColor
        border.color: Material.dividerColor
        border.width: 1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            
            // Иконка
            Text {
                text: parent.parent.icon
                font.pixelSize: 30
                Layout.alignment: Qt.AlignHCenter
            }
            
            // Значение
            Text {
                text: parent.parent.value
                font.pixelSize: 28
                font.bold: true
                color: parent.parent.color
                Layout.alignment: Qt.AlignHCenter
            }
            
            // Заголовок
            Text {
                text: parent.parent.title
                font.pixelSize: 12
                color: Material.color(Material.Grey)
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
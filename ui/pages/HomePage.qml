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
            text: "Добро пожаловать в систему формирования заказов"
            font.pixelSize: 24
            font.bold: true
            Layout.fillWidth: true
        }
        
        // Быстрые действия
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            
            CustomButton {
                text: "Новый заказ"
                iconSource: "+"
                buttonColor: Material.color(Material.Blue)
                Layout.fillWidth: true
                onClicked: stackLayout.currentIndex = 2
            }
            
            CustomButton {
                text: "Каталог"
                iconSource: "📦"
                buttonColor: Material.color(Material.Green)
                Layout.fillWidth: true
                onClicked: stackLayout.currentIndex = 1
            }
            
            CustomButton {
                text: "Заказы"
                iconSource: "📋"
                buttonColor: Material.color(Material.Orange)
                Layout.fillWidth: true
                onClicked: stackLayout.currentIndex = 3
            }
        }
        
        // Статистика
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            
            // Карточка заказов
            Rectangle {
                Layout.fillWidth: true
                height: 120
                radius: 8
                color: Material.backgroundColor
                border.color: Material.dividerColor
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    
                    Text {
                        text: "📋"
                        font.pixelSize: 30
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: totalOrders
                        font.pixelSize: 28
                        font.bold: true
                        color: Material.color(Material.Blue)
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Всего заказов"
                        font.pixelSize: 12
                        color: Material.color(Material.Grey)
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Карточка продуктов
            Rectangle {
                Layout.fillWidth: true
                height: 120
                radius: 8
                color: Material.backgroundColor
                border.color: Material.dividerColor
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    
                    Text {
                        text: "📦"
                        font.pixelSize: 30
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: totalProducts
                        font.pixelSize: 28
                        font.bold: true
                        color: Material.color(Material.Green)
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Продуктов в каталоге"
                        font.pixelSize: 12
                        color: Material.color(Material.Grey)
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Карточка выручки
            Rectangle {
                Layout.fillWidth: true
                height: 120
                radius: 8
                color: Material.backgroundColor
                border.color: Material.dividerColor
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    
                    Text {
                        text: "💰"
                        font.pixelSize: 30
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: totalRevenue.toFixed(2) + " ₽"
                        font.pixelSize: 20
                        font.bold: true
                        color: Material.color(Material.Orange)
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Общая выручка"
                        font.pixelSize: 12
                        color: Material.color(Material.Grey)
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
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
                        text: "Последние заказы"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    CustomButton {
                        text: "Все заказы"
                        flat: true
                        onClicked: stackLayout.currentIndex = 3
                    }
                }
                
                // Список заказов
                ListView {
                    id: recentOrdersList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    model: {
                        if (!backend.orders || backend.orders.length === 0) {
                            return []
                        }
                        // Берем последние 5 заказов
                        var orders = backend.orders.slice()
                        return orders.sort(function(a, b) {
                            return new Date(b.created_at) - new Date(a.created_at)
                        }).slice(0, 5)
                    }
                    
                    delegate: Rectangle {
                        width: recentOrdersList.width
                        height: 60
                        color: index % 2 === 0 ? Material.backgroundColor : Material.color(Material.Grey, Material.Shade50)
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
                                console.log("Просмотр заказа:", modelData.id)
                            }
                        }
                    }
                    
                    // Заглушка если нет заказов
                    Label {
                        anchors.centerIn: parent
                        text: "Нет заказов"
                        visible: recentOrdersList.count === 0
                        font.italic: true
                        color: Material.color(Material.Grey)
                    }
                }
            }
        }
    }
}
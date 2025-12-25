import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "./components"

ApplicationWindow {
    width: 1200
    height: 800
    visible: true
    title: "Система формирования заказов - Электротехническое производство"

    property int currentPageIndex: 0
    
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

    StackLayout {
        id: stackLayout
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        currentIndex: 0

        // Главная страница
        Loader {
            source: "pages/HomePage.qml"
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
                            }
                        }
                    }
                }
            }
        }

        // Создание заказа (новая простая версия)
        Loader {
            source: "pages/OrderFormPage.qml"
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
                        
                        /*
                        Text {
                            text: "Сумма: " + (modelData.total_amount ? modelData.total_amount.toFixed(2) + " ₽" : "")
                            font.pixelSize: 14
                            color: "green"
                        }
                        */
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("Просмотр заказа:", modelData.id)
                    }
                }
            }
        }

        // Статистика и Настройки остаются как есть...
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
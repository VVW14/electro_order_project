
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components"

Page {
    id: homePage
    padding: 20

    //  HTTP (курсы валют) 
    property var currencyRates: ({})

    Component.onCompleted: {
        currencyRates = backend.getCurrencyRates()
    }

    //  Статистика 
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

        //  Заголовок 
        Text {
            text: "Добро пожаловать в систему формирования заказов"
            font.pixelSize: 24
            font.bold: true
            Layout.fillWidth: true
        }

        //  Быстрые действия 
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

        //  Статистика 
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            // Заказы
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

            // Продукты
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
        }

        //  HTTP: курсы валют 
        GroupBox {
            title: "Курсы валют (ЦБ РФ)"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 5

                Text {
                    text: currencyRates.USD
                          ? "USD: " + currencyRates.USD.toFixed(2) + " ₽"
                          : "USD: —"
                }

                Text {
                    text: currencyRates.EUR
                          ? "EUR: " + currencyRates.EUR.toFixed(2) + " ₽"
                          : "EUR: —"
                }

                Text {
                    text: currencyRates.CNY
                          ? "CNY: " + currencyRates.CNY.toFixed(2) + " ₽"
                          : "CNY: —"
                }
            }
        }

        //  Последние заказы 
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

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: backend.orders ? backend.orders.slice(0, 5) : []

                    delegate: Rectangle {
                        height: 50
                        width: parent.width
                        color: index % 2 === 0
                               ? Material.backgroundColor
                               : Material.color(Material.Grey, Material.Shade50)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            Text {
                                text: modelData.order_number
                                font.bold: true
                            }

                            Text {
                                text: modelData.customer_name
                                Layout.fillWidth: true
                            }

                            StatusBadge {
                                status: modelData.status
                            }
                        }
                    }
                }
            }
        }
    }
}

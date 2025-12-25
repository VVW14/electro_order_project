
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Page {
    id: statisticsPage
    padding: 20
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        
        Text {
            text: qsTr("Статистика")
            font.pixelSize: 24
            font.bold: true
            Layout.fillWidth: true
        }
        
        Text {
            text: qsTr("Здесь будет отображаться статистика заказов.")
            Layout.fillWidth: true
        }
    }
}

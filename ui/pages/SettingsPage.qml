import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Page {
    id: settingsPage
    padding: 20
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        
        Text {
            text: qsTr("Настройки")
            font.pixelSize: 24
            font.bold: true
            Layout.fillWidth: true
        }
        
        Text {
            text: qsTr("Настройки приложения.")
            Layout.fillWidth: true
        }
    }
}
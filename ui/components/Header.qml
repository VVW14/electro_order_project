import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: header
    height: 60
    color: "#2196F3"
    
    property string title: ""
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        
        Text {
            text: header.title
            font.pixelSize: 20
            font.bold: true
            color: "white"
            Layout.fillWidth: true
        }
    }
}
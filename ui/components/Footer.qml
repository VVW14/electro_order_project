import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: footer
    height: 40
    color: "#f5f5f5"
    
    property string statusText: ""
    property real progressValue: 0
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        
        Text {
            text: footer.statusText
            font.pixelSize: 12
            color: "#666"
            Layout.fillWidth: true
        }
        
        ProgressBar {
            value: footer.progressValue
            Layout.preferredWidth: 200
            visible: footer.progressValue > 0
        }
    }
}
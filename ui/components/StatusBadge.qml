// ui/components/StatusBadge.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: badge
    height: 24
    radius: 12
    color: getColor(status)
    
    property string status: "Новый"
    
    Text {
        anchors.centerIn: parent
        text: status
        font.pixelSize: 11
        font.bold: true
        color: "white"
        padding: 4
    }
    
    function getColor(status) {
        switch(status) {
            case "Новый": return "#2196F3" // синий
            case "В обработке": return "#FF9800" // оранжевый
            case "Выполнен": return "#4CAF50" // зеленый
            case "Отменен": return "#F44336" // красный
            default: return "#9E9E9E" // серый
        }
    }
}

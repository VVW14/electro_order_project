import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Button {
    id: control
    property color buttonColor: Material.primary
    property color textColor: "white"
    property bool rounded: false
    property real radiusValue: 4
    property string iconSource: ""
    
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    
    padding: 12
    spacing: 8
    
    background: Rectangle {
        id: bgRect
        implicitWidth: 100
        implicitHeight: 40
        color: control.enabled ? control.buttonColor : Material.hintTextColor
        radius: control.rounded ? height / 2 : control.radiusValue
        
        // Эффект нажатия
        Rectangle {
            anchors.fill: parent
            color: control.down ? Qt.darker(control.buttonColor, 1.2) : "transparent"
            radius: parent.radius
        }
        
        // Эффект наведения
        Rectangle {
            anchors.fill: parent
            color: control.hovered ? Qt.lighter(control.buttonColor, 1.1) : "transparent"
            radius: parent.radius
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
    
    contentItem: Row {
        spacing: control.spacing
        layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight
        
        // Иконка как текст (для эмодзи)
        Text {
            id: icon
            text: control.iconSource
            visible: control.iconSource !== ""
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // Текст
        Text {
            id: btnText
            text: control.text
            font: control.font
            color: control.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    // Анимация клика
    Behavior on scale {
        NumberAnimation { duration: 100 }
    }
    
    onClicked: {
        scale = 0.95
        scaleTimer.restart()
    }
    
    Timer {
        id: scaleTimer
        interval: 100
        onTriggered: control.scale = 1.0
    }
}
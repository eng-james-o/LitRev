import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button {
    id: control
    property url btnIconSource: ""
    property color btnColorDefault: "#00000000"
    property color btnColorMouseOver: "#40265d"
    property color btnColorClicked: "#00a1f1"

    property int btnRadius: 5

    QtObject{
        id: internal

        // MOUSE OVER AND CLICK CHANGE COLOR
        property var dynamicColor: if(control.down){
                                       control.down ? btnColorClicked : btnColorDefault
                                   } else {
                                       control.hovered ? btnColorMouseOver : btnColorDefault
                                   }
    }

    width: 40
    height: 30

    background: Rectangle {
        id: bgBtn
        color: internal.dynamicColor
        radius: btnRadius
        anchors.fill: parent
        anchors.margins: 3
        Image {
            id: iconBtn
            source: btnIconSource
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            height: 16
            width: 16
            visible: false
            fillMode: Image.PreserveAspectFit
            antialiasing: false
        }
        ColorOverlay{
            anchors.fill: iconBtn
            source: iconBtn
            color: "#ffffff"
            antialiasing: false
        }
    }
}

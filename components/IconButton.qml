import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button {
    id: control
    property url btnIconSource: ""
    property color btnColorDefault: "#00000000"
    property color btnColorMouseOver: "#40265d"
    property color btnColorClicked: "#00a1f1"
    property color btnOverlayColor: "#ffffff"
    property int btnRadius: 5
    property int iconMargin: 0

    QtObject{
        id: internal

        // MOUSE OVER AND CLICK CHANGE COLOR
        property var dynamicColor: if(control.down){
                                       control.down ? btnColorClicked : btnColorDefault
                                   } else {
                                       control.hovered ? btnColorMouseOver : btnColorDefault
                                   }
        property int iconSize: Math.min(control.width, control.height) - iconMargin
    }

    width: 40
    height: 30

    background: Rectangle {
        id: bgBtn
        color: internal.dynamicColor
        radius: btnRadius
        anchors.fill: parent
        anchors.margins: control.iconMargin

        Image {
            id: iconBtn
            source: btnIconSource
            anchors.centerIn: parent

            height: internal.iconSize; width: internal.iconSize

            visible: false
            fillMode: Image.PreserveAspectFit
            antialiasing: false
        }
        ColorOverlay{
            anchors.fill: iconBtn
            source: iconBtn
            color: control.btnOverlayColor
            antialiasing: false
        }
    }
}

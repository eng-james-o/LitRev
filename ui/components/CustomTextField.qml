import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: field
    property color bg_bottom_color: "#343399"
    property color bg_color: "transparent"
    property real bg_bottom_radius: 1.5

    width: 280; height: 47
    color: "#fafaff"
    placeholderTextColor: "#aabbaa10"
    padding: 8
    font.pointSize: 14


    placeholderText: qsTr("Text Field")

    background: Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            id: bg_bottom_bar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 3
            color: field.bg_bottom_color
            radius: bg_bottom_radius
        }
    }
}

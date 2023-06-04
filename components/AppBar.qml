import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    signal exitClicked
    signal minimizeClicked
    signal maximizeClicked

    height: 40
    radius: 10

    color: "transparent"
    border.width: 0


    Rectangle {
        id: windowtitle
        radius: 10
        height: 30

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: minbtn.left
        anchors.leftMargin: 5

        color: "#75bbf3"
        Label {
            text: "LitRev"
            styleColor: "#000d34"
            font.styleName: "Bold"
            font.pointSize: 16
            font.family: "Verdana"
            anchors.centerIn: parent
        }
    }

    AppBarButton {
        id: minbtn
        anchors.right: maxbtn.left
        anchors.verticalCenter: parent.verticalCenter
        btnIconSource: "../svg/bar.svg"
        onClicked: {root.minimizeClicked()}
    }
    AppBarButton {
        id: maxbtn
        anchors.right: exitbtn.left
        anchors.verticalCenter: parent.verticalCenter
        btnIconSource: "../svg/roundsquare.svg"
        onClicked: {root.maximizeClicked()}
    }
    AppBarButton {
        id: exitbtn
        btnColorClicked: "#aa4545"
        btnColorMouseOver: "#fa6565"
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        btnIconSource: "../svg/exit.svg"
        onClicked: {root.exitClicked()}
    }

}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.9}
}
##^##*/

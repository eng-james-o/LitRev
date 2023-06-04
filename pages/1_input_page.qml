import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Item {
    id: item1

    width: 560
    height: 580

    CustomTextField {
        id: r_text1
        x: 50
        y: 20
        width: 280
        height: 50
        placeholderText: qsTr("Research Question")
        padding: 8
        bg_bottom_color: "white"


        IconButton {
            id: plusbtn
            height: 30
            width: 30

            btnIconSource: "../svg/plus.svg"
            btnOverlayColor: "white"

            anchors {
                right: r_text1.right
                verticalCenter: r_text1.verticalCenter
            }
        }
    }

    CustomRangeSlider {
        id: dateRangeSlider
        anchors.left: r_text1.left
        anchors.right: r_text1.right
        anchors.top: r_text1.bottom
        anchors.topMargin: 50
    }

    CustomTextField {
        id: keywordsField
        height: 43
        anchors.left: r_text1.left
        anchors.right: r_text1.right
        anchors.top: dateRangeSlider.bottom
        anchors.topMargin: 40
        placeholderText: qsTr("Keywords")
        bg_bottom_color: "white"

    }

}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Item {
    id: item1
    signal nextRequested()
    signal backRequested()

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

            btnIconSource: "../../assets/svg/plus.svg"
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

    TextArea {
        id: textArea
        placeholderText: qsTr("Text Area")
    }

    Row {
        id: navRow
        spacing: 10
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20

        Button {
            text: qsTr("Next")
            onClicked: item1.nextRequested()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/

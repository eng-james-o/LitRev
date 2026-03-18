import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts 1.15
import components

Item {
    id: queryGenerationPage
    signal nextRequested()
    signal backRequested()
    width: 560
    height: 580

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Label {
            text: qsTr("Generated Search Queries")
            font.pixelSize: 20
            font.bold: true
            color: "white"
        }

        ListView {
            id: queryList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: JSON.parse(projectController.getSearchQueriesJson())
            delegate: Rectangle {
                width: queryList.width
                height: 80
                color: "#303060"
                radius: 5
                border.color: "#505090"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    Text {
                        text: modelData.query
                        color: "white"
                        font.bold: true
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                    }
                    Text {
                        text: modelData.explanation
                        color: "#cccccc"
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                    }
                }
            }
        }

        Button {
            text: qsTr("Regenerate Queries")
            Layout.alignment: Qt.AlignRight
            onClicked: projectController.generateSearchQueries()
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                text: qsTr("Back")
                onClicked: queryGenerationPage.backRequested()
            }
            Button {
                text: qsTr("Next")
                onClicked: queryGenerationPage.nextRequested()
            }
        }
    }
}

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Item {
    id: searchRetrievalPage
    width: 560
    height: 580

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Label {
            text: qsTr("Searching and Retrieving Articles")
            font.pixelSize: 20
            font.bold: true
            color: "white"
        }

        ProgressBar {
            id: searchProgress
            Layout.fillWidth: true
            value: 0.5 // Simulated progress
        }

        TextArea {
            id: searchLog
            Layout.fillWidth: true
            Layout.fillHeight: true
            readOnly: true
            text: "Initializing search...\nConnecting to arXiv...\nFetching results for query 1...\nFound 5 articles in PubMed..."
            background: Rectangle {
                color: "#202040"
                radius: 5
            }
            color: "#00ff00"
            font.family: "Monospace"
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                text: qsTr("Cancel")
            }
            Button {
                text: qsTr("Start Search")
                onClicked: projectController.searchArticles(0)
            }
        }
    }
}

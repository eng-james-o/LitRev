import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Item {
    id: corpusSelectionPage
    width: 560
    height: 580

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Label {
            text: qsTr("Select Publication Databases")
            font.pixelSize: 20
            font.bold: true
            color: "white"
        }

        ListView {
            id: dbList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: JSON.parse(settingsController.getPublicationDatabasesJson())
            delegate: CheckDelegate {
                width: dbList.width
                text: modelData.name
                checked: modelData.enabled
                onCheckedChanged: projectController.setDatabaseSelected(modelData.name, checked)

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: parent.indicator.width + parent.spacing
                }
            }
        }

        Button {
            text: qsTr("Suggest Databases (AI)")
            Layout.alignment: Qt.AlignHCenter
            onClicked: projectController.suggestDatabases()
        }
    }
}

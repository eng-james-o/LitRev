import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Item {
    id: corpusSelectionPage
    signal nextRequested()
    signal backRequested()

    width: 600
    height: 600

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        ColumnLayout {
            spacing: Style.spacingSmall
            Text {
                text: qsTr("Select Publication Databases")
                color: Style.text
                font.family: Style.fontFamily
                font.pixelSize: Style.fontTitle
                font.bold: true
            }
            Text {
                text: qsTr("Choose the academic databases to search. AI can suggest optimal sources for your topic.")
                color: Style.secondaryText
                font.family: Style.fontFamily
                font.pixelSize: Style.fontBody
            }
        }

        Button {
            id: aiSuggestBtn
            Layout.fillWidth: true
            height: 60
            onClicked: projectController.suggestDatabases()
            contentItem: RowLayout {
                spacing: Style.spacingMedium
                Image {
                    source: "../../assets/svg/hamburger.svg" // Placeholder for AI/Sparkle icon
                    width: 24; height: 24
                    anchors.verticalCenter: parent.verticalCenter
                }
                ColumnLayout {
                    spacing: 0
                    Text {
                        text: qsTr("Suggest Databases (AI)")
                        color: Style.text
                        font.family: Style.fontFamily
                        font.bold: true
                        font.pixelSize: Style.fontBody
                    }
                    Text {
                        text: qsTr("Analyze my research topic for optimal sources")
                        color: Style.secondaryText
                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSmall
                    }
                }
                Item { Layout.fillWidth: true }
                Text { text: "→"; color: Style.text; font.pixelSize: 20 }
            }
            background: Rectangle {
                color: Style.accent
                radius: Style.radiusMedium
                opacity: aiSuggestBtn.down ? 0.8 : 1.0
            }
        }

        ListView {
            id: dbList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Style.spacingSmall
            model: JSON.parse(settingsController.getPublicationDatabasesJson())
            delegate: Rectangle {
                width: dbList.width
                height: 80
                color: Style.surface
                radius: Style.radiusMedium
                border.color: modelData.enabled ? Style.accent : Style.border

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    spacing: Style.spacingMedium

                    CheckBox {
                        id: dbCheckbox
                        checked: modelData.enabled
                        onCheckedChanged: projectController.setDatabaseSelected(modelData.name, checked)
                        // Note: Custom styling for CheckBox would be better here
                    }

                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: modelData.name
                            color: Style.text
                            font.family: Style.fontFamily
                            font.bold: true
                            font.pixelSize: Style.fontBody
                        }
                        Text {
                            text: modelData.description || "Database description..."
                            color: Style.secondaryText
                            font.family: Style.fontFamily
                            font.pixelSize: Style.fontSmall
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingMedium

            Button {
                text: qsTr("← Back to Queries")
                onClicked: corpusSelectionPage.backRequested()
                contentItem: Text {
                    text: parent.text
                    font.family: Style.fontFamily
                    color: Style.secondaryText
                }
                background: Rectangle { color: "transparent" }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Next: Start Retrieval →")
                onClicked: corpusSelectionPage.nextRequested()
                contentItem: Text {
                    text: parent.text
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 40
                    color: Style.accent
                    radius: Style.radiusSmall
                }
            }
        }
    }
}

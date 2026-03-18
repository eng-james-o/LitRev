import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Item {
    id: queryGenerationPage
    signal nextRequested()
    signal backRequested()

    width: 600
    height: 600

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: Style.spacingSmall
                Text {
                    text: qsTr("Generated Search Queries")
                    color: Style.text
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontTitle
                    font.bold: true
                }
                Text {
                    text: qsTr("AI-optimized search strings based on your research problem and keywords.")
                    color: Style.secondaryText
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontBody
                }
            }
            Item { Layout.fillWidth: true }
            Button {
                text: qsTr("Regenerate All")
                onClicked: projectController.generateSearchQueries()
                contentItem: Text {
                    text: parent.text
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.text
                }
                background: Rectangle {
                    implicitWidth: 140; implicitHeight: 40
                    color: "transparent"; border.color: Style.border; radius: Style.radiusSmall
                }
            }
        }

        ListView {
            id: queryList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Style.spacingMedium
            model: JSON.parse(projectController.getSearchQueriesJson())
            delegate: Rectangle {
                width: queryList.width
                height: 180
                color: Style.surface
                radius: Style.radiusMedium
                border.color: Style.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    spacing: Style.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "0" + (index + 1) + ". " + (modelData.title || "Search Query")
                            color: Style.accent
                            font.family: Style.fontFamily
                            font.pixelSize: Style.fontBody
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        // Icons for Copy/Edit could be added here
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Style.windowBackground
                        radius: Style.radiusSmall
                        border.color: Style.border
                        Text {
                            anchors.fill: parent
                            anchors.margins: Style.spacingSmall
                            text: modelData.query
                            color: Style.accent
                            font.family: "Monospace"
                            font.pixelSize: Style.fontSmall
                            wrapMode: Text.Wrap
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: qsTr("RATIONALE")
                            color: Style.secondaryText
                            font.family: Style.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                        }
                        Text {
                            text: modelData.explanation
                            color: Style.secondaryText
                            font.family: Style.fontFamily
                            font.pixelSize: Style.fontSmall
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingMedium

            Button {
                text: qsTr("← Back to Problem Definition")
                onClicked: queryGenerationPage.backRequested()
                contentItem: Text {
                    text: parent.text
                    font.family: Style.fontFamily
                    color: Style.secondaryText
                }
                background: Rectangle { color: "transparent" }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Next: Source Selection →")
                onClicked: queryGenerationPage.nextRequested()
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

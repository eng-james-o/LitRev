import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components
import Style

Item {
    id: searchRetrievalPage
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
                text: qsTr("Searching & Retrieving Articles")
                color: Style.text
                font.family: Style.fontFamily
                font.pixelSize: Style.fontTitle
                font.bold: true
            }
            Text {
                text: qsTr("Real-time execution of search queries across selected academic databases.")
                color: Style.secondaryText
                font.family: Style.fontFamily
                font.pixelSize: Style.fontBody
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 100
            color: Style.surface
            radius: Style.radiusMedium
            border.color: Style.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingMedium
                spacing: Style.spacingSmall

                RowLayout {
                    Text {
                        text: qsTr("OVERALL PROGRESS")
                        color: Style.secondaryText
                        font.family: Style.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "45%" // Mock value
                        color: Style.accent
                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontBody
                        font.bold: true
                    }
                }

                ProgressBar {
                    Layout.fillWidth: true
                    value: 0.45
                    background: Rectangle {
                        implicitWidth: 200; implicitHeight: 6; color: Style.windowBackground; radius: 3
                    }
                    contentItem: Item {
                        implicitWidth: 200; implicitHeight: 6
                        Rectangle {
                            width: parent.parent.visualPosition * parent.width
                            height: parent.height; radius: 3; color: Style.accent
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingLarge

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.surface
                radius: Style.radiusMedium
                border.color: Style.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    spacing: Style.spacingSmall

                    Text {
                        text: qsTr("PROCESS LOG")
                        color: Style.secondaryText
                        font.family: Style.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Style.windowBackground
                        radius: Style.radiusSmall
                        border.color: Style.border

                        ScrollView {
                            anchors.fill: parent
                            TextArea {
                                text: "[14:22:01] Initializing secure connection...\n[14:22:03] Connection established with Scopus API...\n[14:22:05] Executing query: [deep learning] AND [review]...\n[14:22:08] PubMed: Fetching metadata batches (1/4)..."
                                readOnly: true
                                color: Style.success
                                font.family: "Monospace"
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                width: 200
                spacing: Style.spacingMedium

                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    color: Style.surface
                    radius: Style.radiusMedium
                    border.color: Style.border
                    ColumnLayout {
                        anchors.centerIn: parent
                        Text { text: qsTr("Total Articles Found"); color: Style.secondaryText; font.pixelSize: 10 }
                        Text { text: "1,240"; color: Style.text; font.pixelSize: 18; font.bold: true }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    color: Style.surface
                    radius: Style.radiusMedium
                    border.color: Style.border
                    ColumnLayout {
                        anchors.centerIn: parent
                        Text { text: qsTr("Duplicates Removed"); color: Style.secondaryText; font.pixelSize: 10 }
                        Text { text: "312"; color: Style.text; font.pixelSize: 18; font.bold: true }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    color: Style.surface
                    radius: Style.radiusMedium
                    border.color: Style.border
                    ColumnLayout {
                        anchors.centerIn: parent
                        Text { text: qsTr("Success Rate"); color: Style.secondaryText; font.pixelSize: 10 }
                        Text { text: "98.2%"; color: Style.success; font.pixelSize: 18; font.bold: true }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingMedium

            Button {
                text: qsTr("← Back to Selection")
                onClicked: searchRetrievalPage.backRequested()
                contentItem: Text { text: parent.text; font.family: Style.fontFamily; color: Style.secondaryText }
                background: Rectangle { color: "transparent" }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Start Search")
                onClicked: projectController.searchArticles(0)
                contentItem: Text {
                    text: parent.text; font.family: Style.fontFamily; font.bold: true; color: Style.text
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { implicitWidth: 140; implicitHeight: 40; color: Style.surface; border.color: Style.border; radius: Style.radiusSmall }
            }

            Button {
                text: qsTr("Next: Screening →")
                onClicked: searchRetrievalPage.nextRequested()
                contentItem: Text {
                    text: parent.text; font.family: Style.fontFamily; font.bold: true; color: Style.text
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { implicitWidth: 180; implicitHeight: 40; color: Style.accent; radius: Style.radiusSmall }
            }
        }
    }
}

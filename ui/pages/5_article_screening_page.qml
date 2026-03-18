import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components
import Style

Item {
    id: articleScreeningPage
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
                text: qsTr("Screening & Selection")
                color: Style.text
                font.family: Style.fontFamily
                font.pixelSize: Style.fontTitle
                font.bold: true
            }
            Text {
                text: qsTr("Review retrieved articles and determine inclusion based on your criteria. High-confidence AI suggestions are highlighted in blue.")
                color: Style.secondaryText
                font.family: Style.fontFamily
                font.pixelSize: Style.fontBody
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingMedium
            Repeater {
                model: [
                    { label: "TOTAL RETRIEVED", value: "1,240" },
                    { label: "PENDING REVIEW", value: "850" },
                    { label: "INCLUDED", value: "45" },
                    { label: "EXCLUDED", value: "345" }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: Style.surface
                    radius: Style.radiusMedium
                    border.color: Style.border
                    ColumnLayout {
                        anchors.centerIn: parent
                        Text { text: modelData.label; color: Style.secondaryText; font.pixelSize: 8; font.bold: true }
                        Text { text: modelData.value; color: Style.text; font.pixelSize: 16; font.bold: true }
                    }
                }
            }
        }

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

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: qsTr("ARTICLE DETAILS"); color: Style.secondaryText; font.pixelSize: 10; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Text { text: qsTr("YEAR"); color: Style.secondaryText; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 40 }
                    Text { text: qsTr("DATABASE"); color: Style.secondaryText; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 60 }
                    Text { text: qsTr("AI CONFIDENCE"); color: Style.secondaryText; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 80 }
                }

                ListView {
                    id: articleList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: Style.spacingSmall
                    model: JSON.parse(projectController.getArticlesJson())
                    delegate: Rectangle {
                        width: articleList.width
                        height: 70
                        color: modelData.selected ? Style.accent : Style.windowBackground
                        opacity: modelData.selected ? 0.9 : 1.0
                        radius: Style.radiusSmall

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Style.spacingSmall
                            spacing: Style.spacingMedium

                            CheckBox {
                                checked: modelData.selected
                                onCheckedChanged: projectController.setArticleSelected(index, checked)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: modelData.title
                                    color: Style.text
                                    font.bold: true
                                    font.pixelSize: Style.fontBody
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: modelData.authors.join(", ")
                                    color: Style.secondaryText
                                    font.pixelSize: Style.fontSmall
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                text: modelData.year
                                color: Style.text
                                font.pixelSize: Style.fontSmall
                                Layout.preferredWidth: 40
                            }

                            Rectangle {
                                Layout.preferredWidth: 60; height: 18; radius: 4; color: Style.surface
                                Text { anchors.centerIn: parent; text: modelData.source_db; color: Style.accent; font.pixelSize: 9; font.bold: true }
                            }

                            ProgressBar {
                                Layout.preferredWidth: 80
                                value: Math.random() // Placeholder AI confidence
                                background: Rectangle { implicitHeight: 4; color: Style.surface; radius: 2 }
                                contentItem: Item {
                                    Rectangle { width: parent.parent.visualPosition * parent.width; height: 4; radius: 2; color: Style.success }
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingMedium

            Button {
                text: qsTr("← Back to Retrieval")
                onClicked: articleScreeningPage.backRequested()
                contentItem: Text { text: parent.text; font.family: Style.fontFamily; color: Style.secondaryText }
                background: Rectangle { color: "transparent" }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Next: Generate Review →")
                onClicked: articleScreeningPage.nextRequested()
                contentItem: Text {
                    text: parent.text; font.family: Style.fontFamily; font.bold: true; color: Style.text
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { implicitWidth: 180; implicitHeight: 40; color: Style.accent; radius: Style.radiusSmall }
            }
        }
    }
}

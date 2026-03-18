import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components
import Style

Item {
    id: reviewGenerationPage
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
                text: qsTr("Generate Literature Review")
                color: Style.text
                font.family: Style.fontFamily
                font.pixelSize: Style.fontTitle
                font.bold: true
            }
            Text {
                text: qsTr("Synthesize your findings into a structured academic manuscript.")
                color: Style.secondaryText
                font.family: Style.fontFamily
                font.pixelSize: Style.fontBody
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingLarge

            ColumnLayout {
                width: 250
                spacing: Style.spacingMedium

                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: Style.surface
                    radius: Style.radiusMedium
                    border.color: Style.border
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Style.spacingMedium
                        Text { text: qsTr("DATASET SIZE"); color: Style.secondaryText; font.pixelSize: 8; font.bold: true }
                        Text { text: "45 Articles"; color: Style.text; font.pixelSize: 16; font.bold: true }
                        Text { text: qsTr("Selected articles are ready for synthesis."); color: Style.secondaryText; font.pixelSize: 10; Layout.fillWidth: true; wrapMode: Text.Wrap }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingSmall
                    Text { text: qsTr("REVIEW METHODOLOGY"); color: Style.secondaryText; font.pixelSize: 10; font.bold: true }

                    Repeater {
                        model: ["Systematic Review", "Scoping Review", "Narrative Synthesis"]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 60
                            color: Style.surface
                            radius: Style.radiusSmall
                            border.color: methodologyGroup.checkedButton && methodologyGroup.checkedButton.text === modelData ? Style.accent : Style.border

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Style.spacingSmall
                                RadioButton {
                                    id: methodologyRadio
                                    text: modelData
                                    ButtonGroup.group: methodologyGroup
                                    onCheckedChanged: if(checked) projectController.setReviewMethodology(modelData)
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                    ButtonGroup { id: methodologyGroup }
                }

                Button {
                    Layout.fillWidth: true
                    height: 50
                    text: qsTr("Generate Review with AI")
                    onClicked: projectController.generateReview()
                    contentItem: Text {
                        text: parent.text; font.family: Style.fontFamily; font.bold: true; color: Style.text
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle { color: Style.accent; radius: Style.radiusSmall }
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
                    anchors.margins: Style.spacingLarge
                    spacing: Style.spacingMedium

                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: projectController.getReviewContent() === ""
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Style.spacingMedium
                            Text {
                                text: qsTr("Drafting Workspace")
                                color: Style.text; font.pixelSize: 18; font.bold: true; Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: qsTr("Your generated synthesis preview will appear here. Choose a methodology and click generate to begin the AI synthesis process.")
                                color: Style.secondaryText; font.pixelSize: Style.fontBody; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
                            }
                        }
                    }

                    ScrollView {
                        anchors.fill: parent
                        visible: projectController.getReviewContent() !== ""
                        TextArea {
                            text: projectController.getReviewContent()
                            color: Style.text
                            wrapMode: Text.Wrap
                            readOnly: true
                            font.family: Style.fontFamily
                            font.pixelSize: Style.fontBody
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingMedium

            Button {
                text: qsTr("← Back to Screening")
                onClicked: reviewGenerationPage.backRequested()
                contentItem: Text { text: parent.text; font.family: Style.fontFamily; color: Style.secondaryText }
                background: Rectangle { color: "transparent" }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Next: Final Export →")
                onClicked: reviewGenerationPage.nextRequested()
                contentItem: Text {
                    text: parent.text; font.family: Style.fontFamily; font.bold: true; color: Style.text
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { implicitWidth: 180; implicitHeight: 40; color: Style.accent; radius: Style.radiusSmall }
            }
        }
    }
}

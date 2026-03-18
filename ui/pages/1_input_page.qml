import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components
import Style

Item {
    id: inputPage
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
                text: qsTr("Start Your Research")
                color: Style.text
                font.family: Style.fontFamily
                font.pixelSize: Style.fontTitle
                font.bold: true
            }
            Text {
                text: qsTr("Define your parameters to begin the automated systematic literature review.")
                color: Style.secondaryText
                font.family: Style.fontFamily
                font.pixelSize: Style.fontBody
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall
            Text {
                text: qsTr("RESEARCH QUESTION")
                color: Style.accent
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSmall
                font.bold: true
            }
            Rectangle {
                Layout.fillWidth: true
                height: 120
                color: Style.surface
                radius: Style.radiusMedium
                border.color: Style.border
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    TextArea {
                        id: researchQuestionArea
                        placeholderText: qsTr("e.g., What are the long-term impacts of microplastics on marine biodiversity in polar regions?")
                        color: Style.text
                        placeholderTextColor: Style.secondaryText
                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontBody
                        wrapMode: Text.Wrap
                        background: null
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingLarge

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.spacingSmall
                Text {
                    text: qsTr("PUBLICATION YEARS")
                    color: Style.accent
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSmall
                    font.bold: true
                }
                RowLayout {
                    spacing: Style.spacingSmall
                    TextField {
                        id: startYear
                        placeholderText: qsTr("2010")
                        Layout.fillWidth: true
                        color: Style.text
                        background: Rectangle {
                            color: Style.surface
                            radius: Style.radiusSmall
                            border.color: Style.border
                        }
                    }
                    Text { text: "-"; color: Style.secondaryText }
                    TextField {
                        id: endYear
                        placeholderText: qsTr("2024")
                        Layout.fillWidth: true
                        color: Style.text
                        background: Rectangle {
                            color: Style.surface
                            radius: Style.radiusSmall
                            border.color: Style.border
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.spacingSmall
                Text {
                    text: qsTr("KEY SEARCH TERMS")
                    color: Style.accent
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSmall
                    font.bold: true
                }
                TextField {
                    id: searchTerms
                    placeholderText: qsTr("Separate by commas")
                    Layout.fillWidth: true
                    color: Style.text
                    background: Rectangle {
                        color: Style.surface
                        radius: Style.radiusSmall
                        border.color: Style.border
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: Style.spacingMedium

            Button {
                text: qsTr("Save Draft")
                contentItem: Text {
                    text: parent.text
                    font.family: Style.fontFamily
                    color: Style.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 40
                    color: "transparent"
                    border.color: Style.border
                    radius: Style.radiusSmall
                }
            }

            Button {
                text: qsTr("Proceed to Queries →")
                onClicked: {
                    if (researchQuestionArea.text !== "") {
                        projectController.addResearchQuestion(researchQuestionArea.text)
                    }
                    inputPage.nextRequested()
                }
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

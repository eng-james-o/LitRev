import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components
import Style

Item {
    id: editorExportPage
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
                    text: qsTr("Review & Finalize")
                    color: Style.text
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontTitle
                    font.bold: true
                }
                Text {
                    text: qsTr("Project: Impact of AI on Urban Planning (Draft v2)") // Mock project title
                    color: Style.secondaryText
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontBody
                }
            }
            Item { Layout.fillWidth: true }
            RowLayout {
                spacing: Style.spacingMedium
                Button {
                    text: qsTr("Collaborate")
                    contentItem: Text { text: parent.text; color: Style.text; font.family: Style.fontFamily }
                    background: Rectangle { implicitWidth: 100; implicitHeight: 32; color: Style.surface; border.color: Style.border; radius: Style.radiusSmall }
                }
                Button {
                    text: qsTr("Export ↓")
                    onClicked: exportMenu.open()
                    contentItem: Text { text: parent.text; color: Style.text; font.family: Style.fontFamily; font.bold: true }
                    background: Rectangle { implicitWidth: 100; implicitHeight: 32; color: Style.accent; radius: Style.radiusSmall }

                    Menu {
                        id: exportMenu
                        MenuItem { text: "DOCX"; onClicked: projectController.exportReview("docx", "review_export.docx") }
                        MenuItem { text: "PDF"; onClicked: projectController.exportReview("pdf", "review_export.pdf") }
                        MenuItem { text: "Markdown"; onClicked: projectController.exportReview("md", "review_export.md") }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: Style.surface
            radius: Style.radiusSmall
            border.color: Style.border
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Style.spacingMedium
                spacing: Style.spacingLarge
                Text { text: "B"; font.bold: true; color: Style.text }
                Text { text: "I"; font.italic: true; color: Style.text }
                Text { text: "U"; font.underline: true; color: Style.text }
                Rectangle { width: 1; height: 20; color: Style.border }
                Text { text: "List"; color: Style.text }
                Text { text: "Link"; color: Style.text }
                Item { Layout.fillWidth: true }
                Text { text: "1,248 words"; color: Style.secondaryText; font.pixelSize: 10 }
                Text { text: "8 min read"; color: Style.secondaryText; font.pixelSize: 10; anchors.rightMargin: Style.spacingMedium }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Style.surface
            radius: Style.radiusMedium
            border.color: Style.border

            ScrollView {
                anchors.fill: parent
                anchors.margins: Style.spacingLarge
                TextArea {
                    id: editor
                    text: projectController.getReviewContent()
                    color: Style.text
                    wrapMode: Text.Wrap
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontBody
                    background: null
                    onTextChanged: projectController.setReviewContent(text)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingMedium

            Button {
                text: qsTr("← Back to Review Generation")
                onClicked: editorExportPage.backRequested()
                contentItem: Text { text: parent.text; font.family: Style.fontFamily; color: Style.secondaryText }
                background: Rectangle { color: "transparent" }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("+ New Project")
                contentItem: Text {
                    text: parent.text; font.family: Style.fontFamily; font.bold: true; color: Style.text
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { implicitWidth: 180; implicitHeight: 40; color: Style.accent; radius: Style.radiusSmall }
            }
        }
    }
}

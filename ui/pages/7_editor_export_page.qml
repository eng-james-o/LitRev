import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts 
import components

Item {
    id: editorExportPage
    signal nextRequested()
    signal backRequested()
    width: 560
    height: 580

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Label {
            text: qsTr("Review Editor & Export")
            font.pixelSize: 20
            font.bold: true
            color: "white"
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            TextArea {
                id: editor
                text: projectController.getReviewContent()
                color: "white"
                wrapMode: Text.Wrap
                background: Rectangle { color: "#303050"; radius: 5 }
                onTextChanged: projectController.setReviewContent(text)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: qsTr("Export as DOCX")
                onClicked: projectController.exportReview("docx", "review_export.docx")
            }
            Button {
                text: qsTr("Export as PDF")
                // PDF export logic to be implemented
            }
            Button {
                text: qsTr("Export as Markdown")
                onClicked: projectController.exportReview("md", "review_export.md")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                text: qsTr("Back")
                onClicked: editorExportPage.backRequested()
            }
        }
    }
}

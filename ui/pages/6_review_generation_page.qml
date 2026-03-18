import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts 1.15
import components

Item {
    id: reviewGenerationPage
    signal nextRequested()
    signal backRequested()
    width: 560
    height: 580

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Label {
            text: qsTr("Generate Literature Review")
            font.pixelSize: 20
            font.bold: true
            color: "white"
        }

        RowLayout {
            Label { text: "Methodology:"; color: "white" }
            ComboBox {
                id: methodologyCombo
                model: JSON.parse(settingsController.getReviewMethodologiesJson())
                onActivated: projectController.setReviewMethodology(currentText)
            }
        }

        Label {
            text: qsTr("Selected Articles: ") + JSON.parse(projectController.getArticlesJson()).filter(a => a.selected).length
            color: "#cccccc"
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#202040"
            radius: 5

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                visible: projectController.getReviewContent() === ""

                Label {
                    text: qsTr("Ready to generate review")
                    color: "white"
                }

                Button {
                    text: qsTr("Generate Review with AI")
                    onClicked: projectController.generateReview()
                }
            }

            ScrollView {
                anchors.fill: parent
                visible: projectController.getReviewContent() !== ""
                TextArea {
                    text: projectController.getReviewContent()
                    color: "white"
                    wrapMode: Text.Wrap
                    readOnly: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                text: qsTr("Back")
                onClicked: reviewGenerationPage.backRequested()
            }
            Button {
                text: qsTr("Next")
                onClicked: reviewGenerationPage.nextRequested()
            }
        }
    }
}

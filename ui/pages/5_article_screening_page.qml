import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts 1.15
import components

Item {
    id: articleScreeningPage
    signal nextRequested()
    signal backRequested()
    width: 560
    height: 580

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Label {
            text: qsTr("Article Screening")
            font.pixelSize: 20
            font.bold: true
            color: "white"
        }

        ListView {
            id: articleList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: JSON.parse(projectController.getArticlesJson())
            spacing: 5
            delegate: Rectangle {
                width: articleList.width
                height: 100
                color: modelData.selected ? "#404080" : "#303060"
                radius: 5

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    CheckBox {
                        checked: modelData.selected
                        onCheckedChanged: projectController.setArticleSelected(index, checked)
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Text {
                            text: modelData.title
                            color: "white"
                            font.bold: true
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Text {
                            text: modelData.authors.join(", ") + " (" + modelData.year + ")"
                            color: "#bbbbbb"
                            font.pixelSize: 12
                        }
                        Text {
                            text: modelData.source_db
                            color: "#8888ff"
                            font.pixelSize: 11
                        }
                    }

                    Button {
                        text: "Full Text"
                        visible: !modelData.full_text
                        onClicked: projectController.retrieveFullText(index)
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                text: qsTr("Back")
                onClicked: articleScreeningPage.backRequested()
            }
            Button {
                text: qsTr("Next")
                onClicked: articleScreeningPage.nextRequested()
            }
        }
    }
}

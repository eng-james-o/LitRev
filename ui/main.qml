import QtQuick
import QtQuick.Window
import QtQuick.Controls
import components
import pages

Window {
    id: mainwindow
    width: 1024
    height: 768
    visible: true
    color: "#00000000"
    flags: "FramelessWindowHint"

    Rectangle {
        id: bgwindow
        color: Style.windowBackground
        radius: Style.radiusMedium
        border.color: Style.border
        border.width: 1
        anchors.fill: parent
        anchors.margins: 10
        clip: true

        MouseArea {
            id: resizeLeft
            width: 12
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.leftMargin: 0
            anchors.topMargin: 10
            cursorShape: Qt.SizeHorCursor
            DragHandler{
                target: null
                onActiveChanged: if (active) { mainwindow.startSystemResize(Qt.LeftEdge) }
            }
        }

        AppBar {
            id: appbar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            onExitClicked: Qt.quit()
            DragHandler {
                onActiveChanged: if(active){mainwindow.startSystemMove()}}
        }

        Item {
            id: mainframe
            anchors {
                top: appbar.bottom; bottom: parent.bottom
                left: parent.left; right: parent.right
            }

            Component {
                id: inputPageComponent
                InputPage {
                    onNextRequested: rightframe.push(queryGenerationPageComponent)
                }
            }
            Component {
                id: queryGenerationPageComponent
                QueryGenerationPage {
                    onBackRequested: rightframe.pop()
                    onNextRequested: rightframe.push(corpusSelectionPageComponent)
                }
            }
            Component {
                id: corpusSelectionPageComponent
                CorpusSelectionPage {
                    onBackRequested: rightframe.pop()
                    onNextRequested: rightframe.push(searchRetrievalPageComponent)
                }
            }
            Component {
                id: searchRetrievalPageComponent
                SearchRetrievalPage {
                    onBackRequested: rightframe.pop()
                    onNextRequested: rightframe.push(articleScreeningPageComponent)
                }
            }
            Component {
                id: articleScreeningPageComponent
                ArticleScreeningPage {
                    onBackRequested: rightframe.pop()
                    onNextRequested: rightframe.push(reviewGenerationPageComponent)
                }
            }
            Component {
                id: reviewGenerationPageComponent
                ReviewGenerationPage {
                    onBackRequested: rightframe.pop()
                    onNextRequested: rightframe.push(editorExportPageComponent)
                }
            }
            Component {
                id: editorExportPageComponent
                EditorExportPage {
                    onBackRequested: rightframe.pop()
                }
            }

            Rectangle {
                id: menuframe
                property bool opened: true
                state: "opened"
                color: Style.sidebarBackground

                anchors {
                    left: mainframe.left
                    top: mainframe.top; bottom: mainframe.bottom
                }

                Column {
                    anchors.fill: parent
                    anchors.topMargin: Style.spacingMedium
                    spacing: Style.spacingSmall

                    Repeater {
                        model: [
                            { text: "Input", icon: "../assets/svg/plus.svg", page: inputPageComponent, index: 0 },
                            { text: "Queries", icon: "../assets/svg/search.svg", page: queryGenerationPageComponent, index: 1 },
                            { text: "Corpus", icon: "../assets/svg/database.svg", page: corpusSelectionPageComponent, index: 2 },
                            { text: "Search", icon: "../assets/svg/search.svg", page: searchRetrievalPageComponent, index: 3 },
                            { text: "Screening", icon: "../assets/svg/screening.svg", page: articleScreeningPageComponent, index: 4 },
                            { text: "Review", icon: "../assets/svg/review.svg", page: reviewGenerationPageComponent, index: 5 },
                            { text: "Export", icon: "../assets/svg/export.svg", page: editorExportPageComponent, index: 6 }
                        ]

                        delegate: Rectangle {
                            width: menuframe.width - 20
                            height: 40
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: (rightframe.depth > modelData.index) ? Style.accent : "transparent"
                            radius: Style.radiusSmall
                            opacity: (rightframe.depth > modelData.index) ? 1.0 : 0.6

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                spacing: 10

                                Image {
                                    source: modelData.icon
                                    width: 20; height: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.text
                                    color: Style.text
                                    font.family: Style.fontFamily
                                    font.pixelSize: Style.fontBody
                                    visible: menuframe.state === "opened"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }

                states:[
                    State {
                        name: "closed"
                        PropertyChanges {
                            target: menuframe
                            width: 60
                        }
                    },
                    State {
                        name: "opened"
                        PropertyChanges {
                            target: menuframe
                            width: 200
                        }
                    }
                ]
                transitions: [
                    Transition {
                        to:"*"
                        NumberAnimation {
                            target: menuframe
                            property: "width"
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                ]
            }

            StackView {
                id: rightframe

                anchors {
                    left: menuframe.right; right: mainframe.right
                    top: mainframe.top; bottom: mainframe.bottom
                }
                initialItem: inputPageComponent
            }

        }
    }
}

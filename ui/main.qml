import QtQuick
import QtQuick.Window
import QtQuick.Controls
import components
import pages

Window {
    id: mainwindow
    width: 640
    height: 640
    visible: true
    color: "#00000000"
    flags: "FramelessWindowHint"

    Rectangle {
        id: bgwindow
        color: "#484866"
        radius: 10
        border.color: "#33334c"
        border.width: 3
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
        Button {
            id: menu_btn

            width: 50; height: 30
            anchors {
                left: parent.left; leftMargin:5
                top: appbar.top; topMargin: 5
            }

            icon {
                source: "../assets/svg/hamburger.svg"
            }
            display: AbstractButton.IconOnly
            background: Rectangle {
                width: parent.width
                height: parent.height
                color: menu_btn.down?"#202050":"transparent"
            }

            onClicked: {
                menuframe.state = (menuframe.state=="opened"?"closed":"opened")
            }
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

            Item {
                id: menuframe
                property bool opened: false
                state: "closed"

                anchors {
                    left: mainframe.left
                    top: mainframe.top; bottom: mainframe.bottom
                }
                Rectangle {
                    id: menu_bg
                    anchors.fill: parent
                }


                states:[
                    State {
                        name: "closed"
                        PropertyChanges {
                            target: menuframe
                            width: 60
                        }
                        PropertyChanges {
                            target: menu_bg
                            color: "transparent"
                        }
                    },
                    State {
                        name: "opened"
                        PropertyChanges {
                            target: menuframe
                            width: 150
                        }
                        PropertyChanges {
                            target: menu_bg
                            color: "#303090"
                        }
                    }
                ]
                transitions: [
                    Transition {
                        to:"*"
                        NumberAnimation {
                            target: menuframe
                            property: "width"
                            duration: 500
                            easing.type: Easing.Linear
                        }

                        ColorAnimation {
                            duration: 500
                            target: menu_bg
                            property: "color"
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

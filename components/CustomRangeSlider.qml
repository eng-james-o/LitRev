import QtQuick 2.15
import QtQuick.Controls 2.15

RangeSlider {
    id: control
    property bool tooltipVisible: true
    property real handleRadius: 4.5
    property color handleColorDefault: "#f6f6f6"
    property color handleColorPressed: "#f0f0f0"
    property color handleBorderColor: "#bdbebf"
    property color bgColor: "#bdbebf"
    property color bgColorActive: "#21be2b"
    property color tooltipColor: "#21be2b"

    snapMode: RangeSlider.SnapAlways
    stepSize: 1
    to: 2023
    from: 1950
    second.value: 2022
    first.value: 2018

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: control.bgColor

        Rectangle {
            x: control.first.visualPosition * parent.width
            width: control.second.visualPosition * parent.width - x
            height: parent.height
            color: control.bgColorActive
            radius: 2
        }
    }

    first.handle: Rectangle {
        x: control.leftPadding + control.first.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: handleRadius * 2
        implicitHeight: handleRadius * 2
        radius: handleRadius
        color: control.first.pressed ? control.handleColorPressed : control.handleColorDefault
        border.color: control.handleBorderColor
    }

    second.handle: Rectangle {
        x: control.leftPadding + control.second.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: handleRadius * 2
        implicitHeight: handleRadius * 2
        radius: handleRadius
        color: control.second.pressed ? control.handleColorPressed : control.handleColorDefault
        border.color: control.handleBorderColor
    }
    ToolTip {
        id: tooltip_first
        parent: dateRangeSlider.first.handle
        visible: dateRangeSlider.first.hovered
        text: dateRangeSlider.first.value
        contentItem: Text {
            text: tooltip_first.text
            font: tooltip_first.font
            color: "#21be2b"
        }

        background: Rectangle {
            border.color: "#21be2b"
            radius: 4
        }
    }
    ToolTip {
        id: tooltip_second
        parent: dateRangeSlider.second.handle
        visible: dateRangeSlider.second.hovered
        text: dateRangeSlider.second.value
        contentItem: Text {
            text: tooltip_second.text
            font: tooltip_second.font
            color: "#21be2b"
        }

        background: Rectangle {
            border.color: "#21be2b"
            radius: 4
        }
    }
}

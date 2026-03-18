pragma Singleton
import QtQuick

QtObject {
    // Colors
    readonly property color windowBackground: "#0b0e14"
    readonly property color sidebarBackground: "#0f172a"
    readonly property color accent: "#2563eb"
    readonly property color text: "#f8fafc"
    readonly property color secondaryText: "#94a3b8"
    readonly property color surface: "#1e293b"
    readonly property color border: "#334155"
    readonly property color success: "#10b981"
    readonly property color warning: "#f59e0b"
    readonly property color error: "#ef4444"

    // Spacing & Sizing
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24
    readonly property int radiusSmall: 4
    readonly property int radiusMedium: 8
    readonly property int radiusLarge: 12

    // Typography
    readonly property string fontFamily: "Inter"
    readonly property int fontTitle: 24
    readonly property int fontHeader: 18
    readonly property int fontBody: 14
    readonly property int fontSmall: 12

    // Specific component colors (legacy support or refined UI)
    property color pageBackground: windowBackground
    property color toolbarBackground: sidebarBackground
    property color buttonBackground: accent
    property color itemHighlight: accent
}

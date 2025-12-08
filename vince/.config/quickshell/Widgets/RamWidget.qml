// RamWidget.qml
import QtQuick
import "../Services"

Row {
    spacing: 8
    anchors.verticalCenter: parent.verticalCenter
    
    BaseText {
        text: ""
        font.pointSize: 14
    }
    BaseText {
        text: SystemStats.ramUsed
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
    }
}

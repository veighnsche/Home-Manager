// CpuWidget.qml
import QtQuick
import "../Services"

Row {
    spacing: 8
    anchors.verticalCenter: parent.verticalCenter
    
    BaseText {
        text: ""
        font.pointSize: 17
    }
    BaseText {
        text: SystemStats.cpuUsage
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
    }
}

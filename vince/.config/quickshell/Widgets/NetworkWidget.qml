// NetworkWidget.qml
import QtQuick
import "../Services"

Row {
    spacing: 8
    anchors.verticalCenter: parent.verticalCenter
    
    BaseText {
        text: Network.isWired ? "󰈁" : Network.isWifi ? "" : ""
        font.pointSize: 17
    }
    BaseText {
        text: Network.isWired ? Network.connectionStatus : Network.isWifi ? Network.wifiSignal : Network.connectionStatus
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
    }
}

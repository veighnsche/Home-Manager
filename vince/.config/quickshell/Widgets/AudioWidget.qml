// AudioWidget.qml
import QtQuick
import "../Services"

Row {
    spacing: 8
    
    BaseText {
        text: Audio.muted ? "󰝟" : ""
        font.pointSize: 20
    }
    BaseText {
        text: Audio.muted ? "Muted" : Audio.volume
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
    }
}

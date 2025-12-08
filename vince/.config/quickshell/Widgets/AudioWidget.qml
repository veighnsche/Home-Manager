// AudioWidget.qml
import QtQuick
import "../Services"

BaseText {
    text: Audio.muted
        ? " Muted"
        : " " + Audio.volume
}

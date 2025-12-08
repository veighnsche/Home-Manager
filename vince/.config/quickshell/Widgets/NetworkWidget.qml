// NetworkWidget.qml
import QtQuick
import "../Services"

BaseText {
  text: Network.wifiConnected ? "📶 " + Network.wifiSSID + " (" + Network.wifiSignal + ")" : "📶 Disconnected"
}

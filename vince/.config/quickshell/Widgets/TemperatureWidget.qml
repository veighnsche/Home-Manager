// TemperatureWidget.qml
import QtQuick
import "../Services"

BaseText {
  text: "🌡️ CPU: " + Temperature.cpuTemp
}

// SystemStatsWidget.qml
import QtQuick
import "../Services"

BaseText {
  text: "💻 CPU: " + SystemStats.cpuUsage + " | RAM: " + SystemStats.ramUsage
}

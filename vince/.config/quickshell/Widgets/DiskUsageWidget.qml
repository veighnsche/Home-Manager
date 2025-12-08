// DiskUsageWidget.qml
import QtQuick
import "../Services"

BaseText {
  text: "💾 Root: " + DiskUsage.rootUsage + " | Home: " + DiskUsage.homeUsage
}

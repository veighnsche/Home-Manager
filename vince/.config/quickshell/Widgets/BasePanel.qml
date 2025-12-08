// BasePanel.qml
import Quickshell
import QtQuick
import Qt5Compat.GraphicalEffects

PanelWindow {
  color: "transparent"

  Rectangle {
    anchors.fill: parent
    color: "#1f1f1f"
    
    layer.enabled: true
    layer.effect: DropShadow {
      horizontalOffset: 0
      verticalOffset: 8
      radius: 16
      samples: 17
      color: "#AA000000"
    }
  }
}

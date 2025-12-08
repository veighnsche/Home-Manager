// TopBar.qml
import Quickshell
import QtQuick
import "../Widgets"

Scope {
  // no more time object

  BasePanel {
    screen: Quickshell.screens.find(screen => screen.name === "HDMI-A-1")

    anchors {
      top: true
      left: true
      right: true
    }

    margins {
      top: 16
      left: 80
      right: 80
    }

    implicitHeight: 32

    ClockWidget {
      anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: 16
      }

      // no more time binding
    }

    Row {
      anchors {
        right: parent.right
        verticalCenter: parent.verticalCenter
        rightMargin: 16
      }

      spacing: 24

      AudioWidget {}
      SeparatorWidget {}
      DiskUsageWidget {}
      SeparatorWidget {}
      TemperatureWidget {}
      SeparatorWidget {}
      CpuWidget {}
      SeparatorWidget {}
      RamWidget {}
      // NetworkWidget {}
    }
    
  }
}
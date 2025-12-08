// Network.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root
  
  property string wifiSSID: "Disconnected"
  property string wifiSignal: "0%"
  property bool wifiConnected: false
  property bool bluetoothEnabled: false
  
  // WiFi SSID
  Process {
    id: wifiSSIDProc
    command: ["sh", "-c", "iwgetid -r 2>/dev/null || echo 'Disconnected'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        let ssid = this.text.trim();
        root.wifiSSID = ssid || "Disconnected";
        root.wifiConnected = ssid && ssid !== "Disconnected";
      }
    }
  }
  
  // WiFi Signal Strength
  Process {
    id: wifiSignalProc
    command: ["sh", "-c", "iwconfig 2>/dev/null | grep 'Signal level' | awk -F'=' '{print $3}' | awk '{print $1\"%\"}' || echo '0%'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: root.wifiSignal = this.text.trim() || "0%"
    }
  }
  
  // Bluetooth Status
  Process {
    id: bluetoothProc
    command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep 'Powered' | grep -o 'yes' || echo 'no'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: root.bluetoothEnabled = this.text.trim() === 'yes'
    }
  }
  
  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: {
      wifiSSIDProc.running = true;
      wifiSignalProc.running = true;
      bluetoothProc.running = true;
    }
  }
}

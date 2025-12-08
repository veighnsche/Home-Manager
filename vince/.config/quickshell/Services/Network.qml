// Network.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root
  
  property string connectionStatus: "NOT CONNECTED"
  property string connectionIcon: ""
  property string wifiSignal: "<font color='#66ffffff'>-00</font> dBm"
  property bool isConnected: false
  property bool isWired: false
  property bool isWifi: false
  
  // Shared function to format WiFi signal strength in dBm
  // dBm ranges: -30 (excellent) to -90 (very poor)
  function formatWifiSignal(dbm) {
    if (isNaN(dbm)) return "<font color='#66ffffff'>-00</font> dBm";
    
    // dBm is always negative for WiFi signals
    let absDbm = Math.abs(dbm);
    let coloredZero = "<font color='#66ffffff'>-0</font>";
    
    // Color coding based on signal quality
    let signalColor = "";

    if (dbm <= -65) {
      signalColor = "<font color='#ff6b6b'>"; // Very poor - red
    } else if (dbm <= -50) {
      signalColor = "<font color='#ffa726'>"; // Poor - orange
    }

    
    if (absDbm < 10) {
      return coloredZero + signalColor + absDbm + (signalColor ? "</font>" : "") + " dBm";
    } else {
      return signalColor + "-" + absDbm + (signalColor ? "</font>" : "") + " dBm";
    }
  }
  
  // Network connection detection
  Process {
    id: networkStatusProc
    command: ["sh", "-c", "
      # Check for wired connection first
      if ip link show | grep -q 'state UP' && ip route show default | grep -q 'dev enp\\|dev eth\\|dev lan'; then
        echo 'wired'
      # Check for WiFi connection
      elif iwgetid -r 2>/dev/null | grep -q .; then
        echo 'wifi'
      else
        echo 'disconnected'
      fi
    "]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        let status = this.text.trim();
        if (status === 'wired') {
          root.connectionStatus = 'wired';
          root.connectionIcon = ' wired';
          root.isConnected = true;
          root.isWired = true;
          root.isWifi = false;
        } else if (status === 'wifi') {
          root.connectionStatus = '';
          root.connectionIcon = ' wifi';
          root.isConnected = true;
          root.isWired = false;
          root.isWifi = true;
        } else {
          root.connectionStatus = 'NOT CONNECTED';
          root.connectionIcon = '';
          root.isConnected = false;
          root.isWired = false;
          root.isWifi = false;
          root.wifiSignal = "<font color='#66ffffff'>-00</font> dBm";
        }
      }
    }
  }
  
  // WiFi Signal Strength in dBm (only when WiFi is connected)
  Process {
    id: wifiSignalProc
    command: ["sh", "-c", "iwconfig 2>/dev/null | grep 'Signal level' | awk '{for(i=1;i<=NF;i++) if($i ~ /level=/) {split($i,a,\"=\"); print a[2]}}' | sed 's/ dBm//' || echo '-99'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        if (root.isWifi) {
          let signal = this.text.trim();
          if (signal && signal !== '-99') {
            let dbm = parseInt(signal);
            root.wifiSignal = root.formatWifiSignal(dbm);
          } else {
            root.wifiSignal = "<font color='#66ffffff'>-00</font> dBm";
          }
        }
      }
    }
  }
  
  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: {
      networkStatusProc.running = true;
      if (root.isWifi) {
        wifiSignalProc.running = true;
      }
    }
  }
  
  // Run once immediately
  Component.onCompleted: {
    networkStatusProc.running = true;
  }
}

// Temperature.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root
  
  property string cpuTemp: "0°C"
  property string hddTemp: "0°C"
  
  // CPU Temperature
  Process {
    id: cpuTempProc
    command: ["sh", "-c", "sensors | grep 'Core 0' | awk '{print $3}' | head -1"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        let temp = this.text.trim();
        if (temp) {
          root.cpuTemp = temp;
        } else {
          // Fallback for different sensor formats
          cpuTempAltProc.running = true;
        }
      }
    }
  }
  
  // Alternative CPU temp detection
  Process {
    id: cpuTempAltProc
    command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1/1000\"°C\"}' || echo 'N/A'"]
    running: false
    
    stdout: StdioCollector {
      onStreamFinished: {
        let temp = this.text.trim();
        if (temp && temp !== 'N/A') {
          root.cpuTemp = temp + "°C";
        }
      }
    }
  }
  
  // HDD Temperature (requires hddtemp)
  Process {
    id: hddTempProc
    command: ["sh", "-c", "hddtemp /dev/sda 2>/dev/null | awk '{print $3\" \"$4}' || echo 'N/A'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: root.hddTemp = this.text.trim()
    }
  }
  
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: {
      cpuTempProc.running = true;
      hddTempProc.running = true;
    }
  }
}

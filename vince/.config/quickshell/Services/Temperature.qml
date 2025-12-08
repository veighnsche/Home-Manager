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
          // Extract number from temperature string (e.g., "45.0°C" -> 45.0)
          const tempNum = parseFloat(temp.replace(/[^\d.]/g, ''));
          if (!isNaN(tempNum)) {
            if (tempNum < 10) {
              root.cpuTemp = "<font color='#66ffffff'>00</font>" + tempNum.toFixed(0) + "°C";
            } else if (tempNum < 100) {
              root.cpuTemp = "<font color='#66ffffff'>0</font>" + tempNum.toFixed(0) + "°C";
            } else {
              root.cpuTemp = tempNum.toFixed(0) + "°C";
            }
          } else {
            root.cpuTemp = temp;
          }
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
          // Extract number from temperature string
          const tempNum = parseFloat(temp.replace(/[^\d.]/g, ''));
          if (!isNaN(tempNum)) {
            if (tempNum < 10) {
              root.cpuTemp = "<font color='#66ffffff'>00</font>" + tempNum.toFixed(0) + "°C";
            } else if (tempNum < 100) {
              root.cpuTemp = "<font color='#66ffffff'>0</font>" + tempNum.toFixed(0) + "°C";
            } else {
              root.cpuTemp = tempNum.toFixed(0) + "°C";
            }
          } else {
            root.cpuTemp = temp + "°C";
          }
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
    interval: 2000
    running: true
    repeat: true
    onTriggered: {
      cpuTempProc.running = true;
      hddTempProc.running = true;
    }
  }
}

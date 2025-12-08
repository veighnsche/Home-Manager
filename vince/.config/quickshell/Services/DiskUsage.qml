// DiskUsage.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root
  
  property string rootUsage: "0%"
  property string rootUsed: "0GB"
  property string rootTotal: "0GB"
  property string homeUsage: "0%"
  property string homeUsed: "0GB"
  property string homeTotal: "0GB"
  
  // Root partition usage
  Process {
    id: rootDiskProc
    command: ["sh", "-c", "df -h / | tail -1 | awk '{print $3\"/\"$2\" (\"$5\")\"}'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        let parts = this.text.trim().split('/');
        if (parts.length >= 2) {
          root.rootUsed = parts[0].trim();
          let totalAndPercent = parts[1].split('(');
          root.rootTotal = totalAndPercent[0].trim();
          if (totalAndPercent.length > 1) {
            root.rootUsage = totalAndPercent[1].replace(')', '').trim();
          }
        }
      }
    }
  }
  
  // Home partition usage
  Process {
    id: homeDiskProc
    command: ["sh", "-c", "df -h /home 2>/dev/null | tail -1 | awk '{print $3\"/\"$2\" (\"$5\")\"}' || df -h / | tail -1 | awk '{print $3\"/\"$2\" (\"$5\")\"}'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        let parts = this.text.trim().split('/');
        if (parts.length >= 2) {
          root.homeUsed = parts[0].trim();
          let totalAndPercent = parts[1].split('(');
          root.homeTotal = totalAndPercent[0].trim();
          if (totalAndPercent.length > 1) {
            root.homeUsage = totalAndPercent[1].replace(')', '').trim();
          }
        }
      }
    }
  }
  
  Timer {
    interval: 10000
    running: true
    repeat: true
    onTriggered: {
      rootDiskProc.running = true;
      homeDiskProc.running = true;
    }
  }
}

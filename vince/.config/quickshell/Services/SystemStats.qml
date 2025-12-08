// SystemStats.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root
  
  property string cpuUsage: "0%"
  property string ramUsage: "0%"
  property string ramTotal: "0GB"
  property string ramUsed: "0GB"
  
  // CPU Usage
  Process {
    id: cpuProc
    command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1\"%\"}'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: root.cpuUsage = this.text.trim()
    }
  }
  
  // RAM Usage
  Process {
    id: ramProc
    command: ["sh", "-c", "free -h | grep '^Mem:' | awk '{print $3\"/\"$2\" (\"int($3/$2*100)\"%)\"}'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        let parts = this.text.trim().split('/');
        if (parts.length >= 2) {
          root.ramUsed = parts[0].trim();
          let totalAndPercent = parts[1].split('(');
          root.ramTotal = totalAndPercent[0].trim();
          if (totalAndPercent.length > 1) {
            root.ramUsage = totalAndPercent[1].replace(')', '').trim();
          }
        }
      }
    }
  }
  
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: {
      cpuProc.running = true;
      ramProc.running = true;
    }
  }
}

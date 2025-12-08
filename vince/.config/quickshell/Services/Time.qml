// Time.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root
  
  property string formattedDateTime: ""
  
  Process {
    id: timeProc
    command: ["date", "+%B%e %A <font color='#66ffffff'>·</font> %H:%M:%S"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: root.formattedDateTime = this.text.trim() || ""
    }
  }
  
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: timeProc.running = true
  }
}
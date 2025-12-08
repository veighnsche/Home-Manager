// DiskUsage.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  // Display string
  property string homeUsed: "0 GiB"

  // Numeric value if you need it for bars, etc.
  property real homeUsedGiB: 0.0

  // Shared function to format disk usage with leading zeros
  function formatDiskUsage(giB) {
    if (isNaN(giB)) return "0 GiB";
    
    const usedStr = giB.toFixed(1);
    const usedNum = parseFloat(usedStr);
    
    // Convert GB to threshold comparison (600GB = 600, 700GB = 700)
    let colorStart = "";
    let colorEnd = "";
    
    if (usedNum > 700) {
      colorStart = "<font color='#ff6b6b'>";
      colorEnd = "</font>";
    } else if (usedNum > 600) {
      colorStart = "<font color='#ffa726'>";
      colorEnd = "</font>";
    }
    
    if (usedNum < 10) {
      return "<font color='#66ffffff'>00</font>" + colorStart + usedStr + colorEnd + " GiB";
    } else if (usedNum < 100) {
      return "<font color='#66ffffff'>0</font>" + colorStart + usedStr + colorEnd + " GiB";
    } else {
      return colorStart + usedStr + colorEnd + " GiB";
    }
  }

  // Home partition usage (fallback: you can change /home to / if needed)
  Process {
    id: homeDiskProc
    command: [
      "sh", "-c",
      // prints a single number: used bytes
      "df -B1 --output=used /home 2>/dev/null | tail -n 1"
    ]
    running: false

    stdout: StdioCollector {
      onStreamFinished: {
        const txt = this.text.trim();
        if (!txt)
          return;

        const usedBytes = Number(txt);
        if (isNaN(usedBytes))
          return;

        const usedGiB = usedBytes / (1024 * 1024 * 1024);
        root.homeUsedGiB = usedGiB;
        root.homeUsed = root.formatDiskUsage(usedGiB);
      }
    }
  }

  // Poll occasionally – this is fine for disk usage
  Timer {
    interval: 60000    // 60s, change if you want
    running: true
    repeat: true
    onTriggered: {
      homeDiskProc.running = false;
      homeDiskProc.running = true;
    }
  }

  // Run once immediately so you don't see 0 GiB for the first interval
  Component.onCompleted: {
    homeDiskProc.running = true;
  }
}

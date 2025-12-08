// Services/Audio.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property string volume: "<font color='#66ffffff'>000</font> %"
  property bool muted: false

  // Shared function to format volume with leading zeros
  function formatVolume(volumeNum) {
    if (isNaN(volumeNum)) return "0 %";
    
    if (volumeNum === 0) {
      return "<font color='#66ffffff'>000</font> %";
    } else if (volumeNum < 10) {
      return "<font color='#66ffffff'>00</font>" + volumeNum + " %";
    } else if (volumeNum < 100) {
      return "<font color='#66ffffff'>0</font>" + volumeNum + " %";
    } else {
      return volumeNum + " %";
    }
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  function refresh() {
    volumeQuery.running = false;21
    volumeQuery.running = true;
    muteQuery.running = false;
    muteQuery.running = true;
  }

  // ─────────────────────────────────────────────
  // One-shot volume query
  // ─────────────────────────────────────────────
  Process {
    id: volumeQuery
    command: ["sh", "-c",
      "pactl get-sink-volume @DEFAULT_SINK@ | " +
      "awk '{for(i=1;i<=NF;i++) if($i ~ /%$/){print $i; exit}}'"
    ]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const txt = this.text.trim();
        if (txt.length > 0) {
          const volumeNum = parseInt(txt.replace('%', ''));
          root.volume = root.formatVolume(volumeNum);
        }
      }
    }
  }

  // ─────────────────────────────────────────────
  // One-shot mute query
  // ─────────────────────────────────────────────
  Process {
    id: muteQuery
    command: ["sh", "-c",
      "pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'"
    ]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const txt = this.text.trim();
        if (txt === "yes")
          root.muted = true;
        else if (txt === "no")
          root.muted = false;
      }
    }
  }

  // ─────────────────────────────────────────────
  // Event stream: react to volume/mute changes
  // ─────────────────────────────────────────────
  Process {
    id: subscribeProc
    command: ["pactl", "subscribe"]
    running: true

    stdout: SplitParser {
      // read line by line
      splitMarker: "\n"

      onRead: function (data) {
        if (!data)
          return;

        // react only to sink/server changes
        if (data.indexOf("sink") !== -1 || data.indexOf("server") !== -1) {
          root.refresh();
        }
      }
    }
  }
}

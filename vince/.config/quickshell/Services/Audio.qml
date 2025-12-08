// Services/Audio.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property string volume: "0%"
  property bool muted: false

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  function refresh() {
    volumeQuery.running = false;
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
        if (txt.length > 0)
          root.volume = txt;
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

// Time.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string formattedDate: ""
    property string formattedTime: ""
    property string formattedDateTime: ""

    // Function to format time with color coding based on hour
    function formatTimeWithColor(hour, minute, second) {
        let colorStart = "";
        let colorEnd = "";

        // Apply color coding based on time ranges
        if ((hour >= 23) || (hour === 0)) {
            // 23:00-0:00 orange
            colorStart = "<font color='#ffa726'>";
            colorEnd = "</font>";
        } else if (hour >= 1 && hour < 5) {
            // 0:00-5:00 red (excluding 0:00 which is handled above)
            colorStart = "<font color='#ff6b6b'>";
            colorEnd = "</font>";
        } else if (hour >= 5 && hour < 6) {
            // 5:00-6:00 orange
            colorStart = "<font color='#ffa726'>";
            colorEnd = "</font>";
        }

        return colorStart + hour.toString().padStart(2, '0') + ":" + minute.toString().padStart(2, '0') + ":" + second.toString().padStart(2, '0') + colorEnd;
    }

    // Process to get current date and time components
    Process {
        id: timeProc
        command: ["date", "+%B%e %A %H %M %S"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(' ');
                if (parts.length >= 5) {
                    const month = parts[0];
                    const day = parts[1];
                    const weekday = parts[2];
                    const hour = parseInt(parts[3]);
                    const minute = parseInt(parts[4]);
                    const second = parseInt(parts[5]);

                    root.formattedDate = month + " " + day + " " + weekday;
                    root.formattedTime = root.formatTimeWithColor(hour, minute, second);
                    root.formattedDateTime = root.formattedDate + " <font color='#66ffffff'>·</font> " + root.formattedTime;
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: timeProc.running = true
    }
}

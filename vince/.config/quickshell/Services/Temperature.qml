// Temperature.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string cpuTemp: "<font color='#66ffffff'>00</font>0°C"

    // Shared function to format temperature with leading zeros and colors
    function formatTemperature(tempNum) {
        if (isNaN(tempNum))
            return "N/A";

        let formattedTemp;
        if (tempNum < 10) {
            formattedTemp = "<font color='#66ffffff'>00</font>" + tempNum.toFixed(0) + "°C";
        } else if (tempNum < 100) {
            formattedTemp = "<font color='#66ffffff'>0</font>" + tempNum.toFixed(0) + "°C";
        } else {
            formattedTemp = tempNum.toFixed(0) + "°C";
        }

        // Add warning/danger colors
        if (tempNum >= 95) {
            formattedTemp = "<font color='#ff6b6b'>" + formattedTemp + "</font>"; // Danger - red
        } else if (tempNum >= 80) {
            formattedTemp = "<font color='#ffa726'>" + formattedTemp + "</font>"; // Warning - orange
        }

        return formattedTemp;
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
                    const tempNum = parseFloat(temp.replace(/[^\d.]/g, ''));
                    root.cpuTemp = root.formatTemperature(tempNum);
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            // Fallback for different sensor formats
            cpuTempAltProc.running = true;
        }
    }
}

// SystemStats.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Public strings for UI
    property string cpuUsage: "<font color='#66ffffff'>00.0 %</font>"
    property string ramUsed: "<font color='#66ffffff'>00.0 GiB</font>"

    // Optional numeric values if you need them
    property real cpuUsageValue: 0.0
    property real ramUsedGiB: 0.0

    // Internal previous CPU totals for delta calculation
    property double _cpuTotalPrev: 0
    property double _cpuIdlePrev: 0

    // Shared function to format CPU usage with leading zero
    function formatCpuUsage(usage) {
        if (isNaN(usage))
            return "0.0 %";

        let colorStart = "";
        let colorEnd = "";

        // Add warning/danger colors for CPU
        if (usage > 90) {
            colorStart = "<font color='#ff6b6b'>";
            colorEnd = "</font>";
        } else if (usage > 75) {
            colorStart = "<font color='#ffa726'>";
            colorEnd = "</font>";
        }

        return (usage < 10 ? "<font color='#66ffffff'>0</font>" : "") + colorStart + usage.toFixed(1) + colorEnd + " %";
    }

    // Shared function to format RAM usage with leading zero
    function formatRamUsage(giB) {
        if (isNaN(giB))
            return "0.0 GiB";
        const usedStr = giB.toFixed(1);
        const usedNum = parseFloat(usedStr);

        let colorStart = "";
        let colorEnd = "";

        // Add warning/danger colors for RAM (thresholds in GB)
        if (usedNum > 57.5) {
            colorStart = "<font color='#ff6b6b'>";
            colorEnd = "</font>";
        } else if (usedNum > 50) {
            colorStart = "<font color='#ffa726'>";
            colorEnd = "</font>";
        }

        return (usedNum < 10 ? "<font color='#66ffffff'>0</font>" : "") + colorStart + usedStr + colorEnd + " GiB";
    }

    // ───────────────── CPU from /proc/stat ─────────────────
    Process {
        id: cpuProc
        command: ["sh", "-c", "cat /proc/stat | head -n1"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const line = this.text.trim();
                if (!line.startsWith("cpu"))
                    return;

                const parts = line.split(/\s+/);
                // cpu user nice system idle iowait irq softirq steal ...
                if (parts.length < 5)
                    return;

                const user = Number(parts[1]);
                const nice = Number(parts[2]);
                const system = Number(parts[3]);
                const idle = Number(parts[4]);
                const iowait = Number(parts[5] || 0);
                const irq = Number(parts[6] || 0);
                const softirq = Number(parts[7] || 0);
                const steal = Number(parts[8] || 0);

                const total = user + nice + system + idle + iowait + irq + softirq + steal;

                if (root._cpuTotalPrev > 0 && root._cpuIdlePrev >= 0) {
                    const totalDiff = total - root._cpuTotalPrev;
                    const idleDiff = idle - root._cpuIdlePrev;

                    let usage = 0;
                    if (totalDiff > 0) {
                        usage = (totalDiff - idleDiff) * 100.0 / totalDiff;
                    }

                    root.cpuUsageValue = usage;
                    root.cpuUsage = root.formatCpuUsage(usage);
                }

                root._cpuTotalPrev = total;
                root._cpuIdlePrev = idle;
            }
        }
    }

    // ───────────────── RAM from /proc/meminfo ─────────────────
    Process {
        id: ramProc
        command: ["sh", "-c", "cat /proc/meminfo"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text;
                if (!text)
                    return;

                const lines = text.split("\n");
                let memTotalKB = 0;
                let memAvailableKB = 0;

                for (let i = 0; i < lines.length; ++i) {
                    const line = lines[i].trim();
                    if (line.startsWith("MemTotal:")) {
                        // e.g. "MemTotal:       32659260 kB"
                        const parts = line.split(/\s+/);
                        if (parts.length >= 2)
                            memTotalKB = Number(parts[1]);
                    } else if (line.startsWith("MemAvailable:")) {
                        const parts = line.split(/\s+/);
                        if (parts.length >= 2)
                            memAvailableKB = Number(parts[1]);
                    }
                }

                if (memTotalKB <= 0)
                    return;

                const memUsedKB = memTotalKB - memAvailableKB;

                const usedGiB = memUsedKB / (1024 * 1024);

                root.ramUsedGiB = usedGiB;
                root.ramUsed = root.formatRamUsage(usedGiB);
            }
        }
    }

    // ───────────────── Polling timer ─────────────────
    Timer {
        interval: 2000   // 2s
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = false;
            cpuProc.running = true;

            ramProc.running = false;
            ramProc.running = true;
        }
    }

    // Run once immediately so you don't see "0%" on startup
    Component.onCompleted: {
        cpuProc.running = true;
        ramProc.running = true;
    }
}

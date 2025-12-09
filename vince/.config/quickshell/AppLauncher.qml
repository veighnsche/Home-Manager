// AppLauncher.qml
// TEAM_012: Quickshell drun-style application launcher

// QML (Qt Modeling Language) is a declarative language for creating user interfaces
// It uses a hierarchical component structure where each component can have properties, signals, and functions

// Import statements bring in modules - similar to imports in other languages
import Quickshell      // Quickshell-specific components for desktop shells
import QtQuick         // Core QML components for basic UI elements
import QtQuick.Controls // Higher-level UI controls like TextField

// Scope is a Quickshell component that creates a named context/scope
// It acts as the root component that can contain other elements and manage state
Scope {
    id: root

    // === PUBLIC API ===
    // Properties in QML are similar to variables in other languages
    // They can be bound to other properties and trigger updates when changed
    property bool launcherVisible: false

    // Functions in QML can be called from other components or JavaScript code
    // This creates a clean API for external control
    function open() {
        filterText = "";                    // Clear previous search
        launcherVisible = true;             // Show the launcher window
        searchField.forceActiveFocus();     // Give keyboard focus to search input
    }

    function close() {
        launcherVisible = false;            // Hide the launcher window
        filterText = "";                    // Clear search text for next launch
    }

    // === INTERNAL STATE ===
    // This property is bound to the TextField's text property
    // When the user types, this automatically updates and triggers the model filter
    property string filterText: ""

    // === DATA MODEL ===
    // ScriptModel allows you to create a model from JavaScript code
    // Models are used by ListView to display dynamic data
    // This model automatically updates when filterText changes

    // DesktopEntries is a singleton provided by Quickshell
    // Singletons are accessed directly without instantiation
    // .applications.values gives us all installed desktop applications
    ScriptModel {
        id: filteredApps
        // The values property contains an array of application objects
        // Each object has properties like name, execute(), icon, etc.
        values: DesktopEntries.applications.values.filter(entry => {
            if (filterText === "")
                return true;  // Show all apps when no filter
            // Case-insensitive search - toLowerCase() makes it user-friendly
            return entry.name.toLowerCase().includes(filterText.toLowerCase());
        })
    }

    // === USER INTERFACE ===
    // FloatingWindow creates a window that can appear anywhere on screen
    // It's positioned relative to screen coordinates, not parent widgets
    FloatingWindow {
        id: launcherWindow
        visible: root.launcherVisible  // Property binding - window follows launcherVisible state
        title: "App Launcher"

        // Screen targeting - find specific monitor by name
        // Quickshell.screens provides access to all connected displays
        screen: Quickshell.screens.find(screen => screen.name === "HDMI-A-1")

        // Fixed dimensions for consistent appearance
        width: 400
        height: 500

        // Transparent window background allows custom shaped windows
        color: "transparent"

        // Rectangle provides the actual visible background
        // Since the window is transparent, we need our own background
        Rectangle {
            anchors.fill: parent  // Fill the entire FloatingWindow
            color: "#2d2d2d"     // Dark background color
            radius: 8             // Rounded corners for modern look

            // Column arranges children vertically with automatic spacing
            Column {
                anchors.fill: parent
                anchors.margins: 12  // Inner padding
                spacing: 8           // Space between elements

                // === SEARCH INPUT ===
                // TextField is a text input component from QtQuick.Controls
                // It provides text editing, cursor management, and keyboard handling
                TextField {
                    id: searchField
                    width: parent.width
                    height: 36
                    placeholderText: "Search applications..."

                    // Two-way data binding: when user types, filterText updates
                    // When filterText changes programmatically, TextField updates
                    text: root.filterText
                    onTextChanged: root.filterText = text

                    // Custom styling - override default appearance
                    background: Rectangle {
                        color: "#1f1f1f"  // Darker background for input field
                        radius: 4         // Slightly rounded corners
                    }

                    color: "#ffffff"              // White text color
                    placeholderTextColor: "#888888"  // Gray placeholder text

                    // === KEYBOARD HANDLING ===
                    // QML provides convenient signal handlers for common keys
                    Keys.onEscapePressed: root.close()  // Close launcher on Escape
                    Keys.onDownPressed: appList.forceActiveFocus()  // Move focus to app list
                    Keys.onReturnPressed: {
                        // Launch first app when Enter is pressed in search field
                        if (filteredApps.values.length > 0) {
                            filteredApps.values[0].execute();  // Execute the application
                            root.close();                      // Close launcher after launch
                        }
                    }
                }

                // === APPLICATION LIST ===
                // ListView efficiently displays large datasets by only creating visible items
                // It's much more performant than Column/Repeater for long lists
                ListView {
                    id: appList
                    width: parent.width
                    // Calculate height to fill remaining space after search field
                    height: parent.height - searchField.height - parent.spacing
                    clip: true  // Hide items that scroll outside bounds
                    model: filteredApps  // Use our filtered data model
                    currentIndex: 0     // Start with first item selected

                    // Delegate defines how each item in the list should look
                    // modelData contains the current item from the model
                    delegate: Rectangle {
                        width: appList.width
                        height: 40
                        // Conditional styling based on selection state
                        color: ListView.isCurrentItem ? "#3d3d3d" : "transparent"
                        radius: 4

                        // Display application name
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            text: modelData.name  // Access the name property of app entry
                            color: "#ffffff"
                            font.pixelSize: 14
                        }

                        // MouseArea makes the item interactive
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: appList.currentIndex = index  // Select on hover
                            onClicked: {
                                modelData.execute();  // Launch the application
                                root.close();         // Close launcher
                            }
                        }
                    }

                    // === LIST KEYBOARD NAVIGATION ===
                    Keys.onEscapePressed: root.close()  // Close on Escape
                    Keys.onUpPressed: {
                        if (currentIndex > 0)
                            currentIndex--;
                        else
                            // Move up, or...
                            searchField.forceActiveFocus();     // ...return to search field
                    }
                    Keys.onDownPressed: {
                        if (currentIndex < count - 1)
                            currentIndex++;  // Move down in list
                    }
                    Keys.onReturnPressed: {
                        // Launch currently selected application
                        if (currentItem && currentIndex >= 0) {
                            filteredApps.values[currentIndex].execute();
                            root.close();
                        }
                    }
                }
            }
        }
    }
}

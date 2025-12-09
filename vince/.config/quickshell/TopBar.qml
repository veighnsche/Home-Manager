// TopBar.qml
// TEAM_012: Added launcher property and button

// QML Component Architecture:
// - Components are reusable UI building blocks
// - Properties allow data flow between components
// - Required properties must be provided by parent component

import Quickshell      // Quickshell desktop shell framework
import QtQuick         // Core QML components
import "./Widgets"     // Import custom widget components from local directory

// Scope creates a named context that can contain other components
// It's the root component that manages the overall bar layout
Scope {
  // === COMPONENT INJECTION ===
  // 'required property' means this component expects the parent to provide this value
  // This creates a dependency injection pattern - the launcher is passed in from shell.qml
  // This allows TopBar to control the AppLauncher without creating its own instance
  required property var launcher

  // BasePanel is a custom component (likely from Quickshell) that provides
  // common panel functionality like positioning, styling, and screen management
  BasePanel {
    id: basePanel
    // Target specific screen by name - ensures bar appears on correct monitor
    screen: Quickshell.screens.find(screen => screen.name === "HDMI-A-1")

    // Anchor system - QML's layout system for positioning relative to parent
    anchors {
      top: true     // Stick to top of screen
      left: true    // Stretch from left edge
      right: true   // Stretch to right edge
    }

    // Margins create spacing from screen edges
    margins {
      top: 16        // 16px from top
      left: 80       // 80px from left (avoid overlapping with other UI)
      right: 80      // 80px from right
    }

    // Fixed height ensures consistent bar appearance
    implicitHeight: 32

    // === APP LAUNCHER BUTTON ===
    // This button triggers the AppLauncher component
    // It demonstrates component communication through property injection
    Rectangle {
      id: launcherButton
      anchors {
        left: parent.left               // Position at left edge of bar
        verticalCenter: parent.verticalCenter  // Center vertically
        leftMargin: 16                  // 16px padding from left edge
      }
      width: 24
      height: 24
      radius: 4                         // Rounded corners for modern look
      
      // Dynamic color based on mouse hover state
      // This creates visual feedback for user interaction
      color: launcherMouseArea.containsMouse ? "#3d3d3d" : "transparent"
      
      // Unicode character for application launcher icon
      Text {
        anchors.centerIn: parent         // Center text in button
        text: "⊞"                       // Windows-style app launcher symbol
        color: "#ffffff"                 // White text
        font.pixelSize: 16               // Appropriate size for 24px button
      }
      
      // MouseArea makes the Rectangle interactive
      // Without this, Rectangle wouldn't respond to mouse events
      MouseArea {
        id: launcherMouseArea
        anchors.fill: parent             // Cover entire button area
        hoverEnabled: true               // Enable hover detection for color changes
        
        // === COMPONENT COMMUNICATION ===
        // When clicked, call the open() method on the injected launcher component
        // This demonstrates how components communicate through property injection
        // The launcher object was passed in from shell.qml as a required property
        onClicked: launcher.open()
      }
    }

    // === SYSTEM WIDGETS ===
    // Custom widgets are imported from "./Widgets" directory
    // Each widget is likely a separate QML file with its own component definition
    
    ClockWidget {
      anchors {
        left: launcherButton.right      // Position after launcher button
        verticalCenter: parent.verticalCenter
        leftMargin: 16                  // Spacing between launcher and clock
      }
      // Widget handles its own time updates internally
    }

    // Row arranges multiple widgets horizontally with automatic spacing
    // This creates the right-side system monitoring area
    Row {
      anchors {
        right: parent.right              // Stick to right edge of bar
        verticalCenter: parent.verticalCenter
        rightMargin: 16                  // Padding from right edge
      }

      spacing: 16                        // 16px between each widget

      // System monitoring widgets - each handles its own data updates
      // These demonstrate component composition and modular design
      AudioWidget {}      // Audio volume/control
      SeparatorWidget {}  // Visual separator between widgets
      DiskUsageWidget {}  // Disk space monitoring
      SeparatorWidget {}  // Visual separator
      TemperatureWidget {} // System temperature
      SeparatorWidget {}  // Visual separator
      CpuWidget {}        // CPU usage monitoring
      SeparatorWidget {}  // Visual separator
      RamWidget {}        // Memory usage monitoring
      SeparatorWidget {}  // Visual separator
      NetworkWidget {}    // Network status monitoring
    }
    
  }
}
// shell.qml
// TEAM_012: Added AppLauncher instantiation
import Quickshell

Scope {
  // TEAM_012: App launcher instance, accessible from TopBar
  AppLauncher {
    id: appLauncher
  }

  TopBar {
    // TEAM_012: Pass launcher reference to TopBar
    launcher: appLauncher
  }
}
// ClockWidget.qml
import QtQuick
import "../Services"

BaseText {
  // we no longer need time as an input
  
  // directly access the time property from the Time singleton
  text: Time.formattedDateTime
}
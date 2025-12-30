import Ubuntu.Components.Popups 1.3


import QtQuick 2.7
import QtQuick.Controls 2.7
import QtQuick.Dialogs 1.3
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4
import Ubuntu.Components 1.3


Rectangle {
    id: text_rect
    // Set a minimum width for the rectangle
    implicitWidth: textItem.width + units.gu(5)  // Adding padding
    height: units.gu(10)
    color: "lightblue"
    radius: units.gu(5)  // This sets the rounded corners

    Text {
        id: textItem  // Assign an ID to reference this Text item
        text: "Welcome to Sketcher!"  // You can change this text as needed
        anchors.centerIn: parent
        font.pointSize: units.gu(1)
        color: "black"
    }

    // Define states
    states: [
        State {
            name: "expanded"
            PropertyChanges {
                target: text_rect
                height: units.gu(7)
                visible: true
            }
        },
        State {
            name: "collapsed"
            PropertyChanges {
                target: text_rect
                height: 0
                visible: false
            }
        }
    ]

    // Define transitions
    transitions: Transition {
        from: "expanded"
        to: "collapsed"
        reversible: true
        //PauseAnimation { duration: 3000 } // 1 second delay
        NumberAnimation { properties: "height"; duration: 1000 }
        NumberAnimation { properties: "visible"; duration: 1000 }
    }
    

    // Initial state
    state: "collapsed"

    // Function to restart the animation
    function toggleState() {
        if (text_rect.state === "expanded") {
            text_rect.state = "collapsed";
        } else {
            text_rect.state = "expanded";
        }
    }
    function showText(newtext){
        textItem.text = newtext;
        text_rect.state = "expanded";
        stateTimer.restart();
    }

    Timer {
        id: stateTimer
        interval: 2000 // Change state every 2 seconds
        repeat: false
        running: true
        onTriggered: {
            toggleState();
        }
    }


    // Example of emitting the signal
    Component.onCompleted: {
        // Emit the signal to change the button state after 3 seconds
        //stateTimer.start();
        toggleState();
        
    }
}
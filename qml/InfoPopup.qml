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


Popup {
    id: infoPopup
    property string api_key: ""

    //anchors.centerIn: parent
    width: parent.width - units.gu(1)
    focus: true
        
    
    Column{
        spacing: units.gu(2)
        anchors.fill: parent
        anchors.margins: units.gu(2)

        Label{
            id: popupHeaderlabel
            width: parent.width
            height: units.gu(3)
            text: "- Settings -"
            font.bold: true
        }

        Label{
            id: popupAPIlabel
            width: parent.width
            height: units.gu(3)
            text: "Todoist API token"
            wrapMode: "WordWrap"
        }

        TextField {
            id: popupAPIkey
            width: parent.width
            height: units.gu(3)
            placeholderText: "Enter token here"
            text: infoPopup.api_key
            

            // Add a new signal here
            signal keyPressed(var event)

            // Connect the existing signal to our new signal
            Keys.onPressed: keyPressed(event)
        }
    
        Row {
            id: popupRowButtons
            spacing: units.gu(1)
            Button {
                text: "Close"
                onClicked: infoPopup.close()
            }
            Button {
                text: "Apply"
                onClicked: {
                    progress.running = true; 
                    Db.updateSetting2("api_key", popupAPIkey.text);
                    root.api_key = popupAPIkey.text;
                    root.init_python();
                    root.loadStructure();
                    root.setting_dialog_open = false;
                    infoPopup.close()
                }
            }
        }
    }

    Connections {
        target: popupAPIkey
        onKeyPressed: {
            infoPopup.api_key = popupAPIkey.text
        }
    }
    Component.onCompleted:{
        console.log("Settings dialog opened");
        popupAPIkey.text = Db.getSetting("api_key");
    }
}
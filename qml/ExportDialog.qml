import QtQuick 2.4
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.0
import Lomiri.Content 1.1


// From Brian Douglass
// https://gitlab.com/bhdouglass/finger-painting/-/tree/47c9da9f5861a446cf127f8011595d71ba2a5cd9/qml

PopupBase {
    id: exportDialog
    anchors.fill: parent
    property var activeTransfer
    property var path

    Rectangle {
        anchors.fill: parent

        ContentItem {
            id: exportItem
        }

        ContentPeerPicker {
            id: peerPicker
            visible: exportDialog.visible
            handler: ContentHandler.Destination
            contentType: ContentType.Pictures

            onPeerSelected: {
                activeTransfer = peer.request();
                var items = [];
                exportItem.url = path;
                items.push(exportItem);

                activeTransfer.items = items;
                activeTransfer.state = ContentTransfer.Charged;

                PopupUtils.close(exportDialog);
            }

            onCancelPressed: {
                PopupUtils.close(exportDialog);
            }
        }
    }
}

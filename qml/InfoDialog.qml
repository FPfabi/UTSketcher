import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Dialog {
    id: infoDialog
    title: i18n.tr("Wrong context")
    property var infomsg

    Label {
        id: msg
		width: parent.width
		wrapMode: Text.WordWrap
        text: infomsg
    }

    Button {
        text: i18n.tr("Close")
        onClicked: PopupUtils.close(infoDialog)
    }
}

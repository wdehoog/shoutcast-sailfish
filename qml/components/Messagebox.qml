import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem
{
    id: messagebox
    z: 20
    visible: messageboxVisibility.running
    height: messageboxText.height + Theme.paddingLarge
    anchors.centerIn: parent
    onClicked: messageboxVisibility.stop()
    //opacity: 0


    Rectangle {
        height: Theme.paddingSmall
        width: parent.width
        color: Theme.highlightBackgroundColor
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.8)
    }

    function showMessage(message, delay)
    {
        messageboxText.text = message
        messageboxVisibility.interval = (delay>0) ? delay : 3000
        messageboxVisibility.restart()
    }

    TextArea {
        id: messageboxText
        width: parent.width - 2*Theme.paddingMedium
        x: Theme.paddingMedium
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        wrapMode: Text.Wrap
        text: ""
        anchors.centerIn: parent
    }

    Timer {
        id: messageboxVisibility
        interval: 3000
    }
}

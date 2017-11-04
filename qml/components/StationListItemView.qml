import QtQuick 2.0
import Sailfish.Silica 1.0

import "../shoutcast.js" as Shoutcast
import "../"

Column {

    width: parent.width

    Item {
        width: parent.width
        height: nameLabel.height

        Label {
            id: nameLabel
            color: currentItem === index ? Theme.highlightColor : Theme.primaryColor
            textFormat: Text.StyledText
            truncationMode: TruncationMode.Fade
            width: parent.width - countLabel.width
            text: name
        }
        Label {
            id: countLabel
            anchors.right: parent.right
            color: currentItem === index ? Theme.secondaryHighlightColor : Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            text: lc + " - " + Shoutcast.getAudioType(mt) + "/" + br
        }
    }

    Label {
        color: currentItem === index ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
        textFormat: Text.StyledText
        truncationMode: TruncationMode.Fade
        width: parent.width
        text: (genre ? (genre + " - ") : "") + (ct ? ct : qsTr("no track info"))
    }
}


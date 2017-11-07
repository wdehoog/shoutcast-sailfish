import QtQuick 2.0
import Sailfish.Silica 1.0

import "../shoutcast.js" as Shoutcast
import "../"

Column {
    id: stationListItemViewColumn
    width: parent.width

    // name    lc, mt/br
    // ct

    /*Item {
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
    }*/

    // name
    // lc, genre, mt/br
    // ct

    Label {
        id: nameLabel
        width: parent.width
        color: currentItem === index ? Theme.highlightColor : Theme.primaryColor
        textFormat: Text.StyledText
        truncationMode: TruncationMode.Fade
        text: name
    }

    Label {
        id: metaLabel
        width: parent.width
        color: currentItem === index ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
        truncationMode: TruncationMode.Fade
        text: getMetaString(model)
    }

    Label {
        id: trackLabel
        width: parent.width
        color: currentItem === index ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
        textFormat: Text.StyledText
        truncationMode: TruncationMode.Fade
        text: ct ? ct : qsTr("no track info")
    }

    function getMetaString(model) {
        var mstr = ""
        if(model.lc)
            mstr += lc;
        var gstr = genreString(model)
        if(gstr.length > 0) {
            if(mstr.length > 0)
                mstr += ", "
            mstr += gstr
        }
        if(model.mt) {
            if(mstr.length > 0)
                mstr += ", "
            mstr += Shoutcast.getAudioType(model.mt)
        }
        if(model.br) {
            if(mstr.length > 0)
                mstr += "/"
            mstr += model.br
        }
        return mstr
    }

    function genreString(model) {
        //console.log(model.id + ": l=" + model.ct.length + ", text=" + model.ct)
        var str = ""
        if(model.genre)
            str += genre
        if(model.genre2)
            str += ", " + genre2
        if(model.genre3)
            str += ", " + genre3
        if(model.genre4)
            str += ", " + genre4
        if(model.genre5)
            str += ", " + genre5
        return str
    }
}


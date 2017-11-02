/*
 * Donnie. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    property string defaultImageSource : app.getAppIconSource2(Theme.iconSizeLarge) //"image://theme/icon-l-music"
    property string imageSource : defaultImageSource
    property string playIconSource : "image://theme/icon-cover-play"
    property string metaText: ""

    Column {
        width: parent.width

        //anchors.topMargin: Theme.paddingMedium
        //anchors.top: parent.top + Theme.paddingMedium
        // nothing works. try a filler...
        Rectangle {
            width: parent.width
            height: Theme.paddingMedium
            opacity: 0
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            id: label
            text: qsTr("Shoutcast")
            horizontalAlignment: Text.AlignHCenter
            visible: imageSource.toString().length == 0
        }

        Item {
            id: imageItem
            width: parent.width - (Theme.paddingMedium * 2)
            height: width
            x: Theme.paddingMedium

            Image {
                id: image
                width: imageSource === defaultImageSource ? sourceSize.width : parent.width
                height: width
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: imageSource
            }
        }

        Text {
            id: meta
            height: parent.height - Theme.paddingMedium - label.height - imageItem.height - coverAction.height
            width: parent.width - 2 * Theme.paddingMedium
            x: Theme.paddingMedium
            text: metaText
            horizontalAlignment:  Text.AlignHCenter
            //visible: imageSource === defaultImageSource
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            wrapMode: Text.Wrap
        }

        /*Label {
            id: meta
            anchors.margins: Theme.paddingMedium
            text: metaText.length > 0 ? metaText : qsTr("Shoutcast")
            horizontalAlignment:  Text.AlignHCenter
            visible: imageSource === defaultImageSource
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor

            NumberAnimation {
                id: animation
                target: meta
                properties: "x"
                from: 0 //parent.width
                to: -1 * meta.width
                loops: Animation.Infinite
                duration: 10000
                running: meta.width > parent.width
            }
        }*/

        CoverActionList {
            id: coverAction

            CoverAction {
                iconSource: "image://theme/icon-cover-previous"
                onTriggered: app.prev()
            }

            CoverAction {
                iconSource: playIconSource
                onTriggered: app.pause()
            }

            CoverAction {
                iconSource: "image://theme/icon-cover-next"
                onTriggered: app.next()
            }
        }

    }
}


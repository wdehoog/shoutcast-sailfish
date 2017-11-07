//pragma Singleton
import QtQuick 2.0 
import Sailfish.Silica 1.0
import QtMultimedia 5.5

import "../shoutcast.js" as Shoutcast
import "../"

DockedPanel {
    id: panel


    property alias swipe: mouse
    property alias page: mouse.page
    property alias playerButtons: playerButtons

    width: parent.width
    height: Math.min(playerUI.height + Theme.paddingSmall, parent.height/2)

    open: app.audio.source && app.audio.source.toString().length > 0
    dock: Dock.Bottom

    property string defaultImageSource: "image://theme/icon-m-music"
    property string playIconSource: app.audio.playbackState === Audio.PlayingState
                                    ? "image://theme/icon-m-pause"
                                    : "image://theme/icon-m-play"

    onPlayIconSourceChanged: cover.playIconSource = playIconSource

    Connections {
        target: app
        onNextRequested: next()
        onPreviousRequested: previous()
    }

    Row {
        id: playerUI

        //height: Math.max(imageItem.height, meta.height, playerButtons.height)
        width: parent.width

        Image {
            id: imageItem
            source: app.logoURL.length > 0 ? app.logoURL : defaultImageSource
            width: Theme.iconSizeLarge
            height: width
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
        }

        Column {
            id: meta
            width: parent.width - imageItem.width - playerButtons.width
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: m1
                x: Theme.paddingSmall
                width: parent.width - Theme.paddingSmall
                color: Theme.primaryColor
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: app.streamMetaText1
            }
            Text {
                id: m2
                x: Theme.paddingSmall
                width: parent.width- Theme.paddingSmall
                anchors.right: parent.right
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: app.streamMetaText2
            }

        }

        Row {
          id: playerButtons

          anchors.verticalCenter: parent.verticalCenter
          spacing: Theme.paddingSmall
          width: playIcon.width + Theme.paddingSmall

          IconButton {
              id: playIcon
              z: 1
              icon.source: playIconSource
              onClicked: app.pause()
          }

       }
    }

    signal previous()
    signal next()

    SwipeArea {
        id: mouse
        anchors.top: parent.top
        x: 0
        width: parent.width - playerButtons.width
        height: parent.height
        swipeTreshold: 45

        //onMove: content.x = (-root.width * currentIndex) + x

        onSwipe: {
             switch (direction) {
             //case dirUp:
             case dirLeft:
                 previous()
                 break
             //case dirDown:
             case dirRight:
                 next()
                 break
             }
         }

         //onCanceled:  currentIndexChanged()
     }
}

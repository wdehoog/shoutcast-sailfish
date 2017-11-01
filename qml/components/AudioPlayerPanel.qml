//pragma Singleton
import QtQuick 2.0 
import Sailfish.Silica 1.0
import QtMultimedia 5.5

import "../shoutcast.js" as Shoutcast
import "../"

DockedPanel {
    id: panel

    width: parent.width
    height: playerUI.height + Theme.paddingSmall

    open: audio.source && audio.source.toString().length > 0
    dock: Dock.Bottom

    property string defaultImageSource: "image://theme/icon-m-music"
    property string playIconSource: app.audio.playbackState === Audio.PlayingState
                                    ? "image://theme/icon-m-pause"
                                    : "image://theme/icon-m-play"

    onPlayIconSourceChanged: cover.playIconSource = playIconSource

    Connections {
        target: app
        onAudioBufferFull: play()
        onPlayRequested: play()
        onPauseRequested: pause()
    }

    function play() {
        app.audio.play()
    }

    function pause() {
        if(app.audio.playbackState === Audio.PlayingState)
            app.audio.pause()
        else
            play()
    }

    Row {
        id: playerUI

        width: parent.width

        Image {
            id: imageItem
            source: app.logoURL.length > 0 ? app.logoURL : defaultImageSource
            width: parent.width / 4
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
              icon.source: playIconSource
              onClicked: pause()
          }

       }
    }
}

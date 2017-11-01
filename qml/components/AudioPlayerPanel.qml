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

    open: audio.hasAudio
    dock: Dock.Bottom

    property string defaultImageSource : "image://theme/icon-m-music"
    property string playIconSource : "image://theme/icon-m-play"

    Component.onCompleted: updateIcons()

    Connections {
        target: app
        onStationChanged: {
            updateIcons()
        }

        onPlaybackStateChanged: updateIcons()
        onAudioBufferFull: play()
        onPlayRequested: play()
        onPauseRequested: pause()
    }

    function play() {
        app.audio.play()
        updateIcons()
    }

    function pause() {
        if(app.audio.playbackState === Audio.PlayingState) {
            app.audio.pause()
            updateIcons()
        } else {
            play()
        }
    }

    /*function stop() {
        app.audio.stop()
        app.audio.source = ""
        updateIcons()
    }*/

    function updateIcons() {
        if(app.audio.playbackState === Audio.PlayingState) {
            playIconSource = "image://theme/icon-m-pause";
            cover.playIconSource = "image://theme/icon-cover-pause";
        } else {
            playIconSource =  "image://theme/icon-m-play";
            cover.playIconSource = "image://theme/icon-cover-play";
        }
    }

    Row {
        id: playerUI

        width: parent.width

        Image {
            id: imageItem
            source: app.logoURL.length > 0 ? app.logoURL : defaultImageSource
            width: parent.width / 4
            height: width
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
                text: app.streamMetaText2 //lc + " " + Shoutcast.getAudioType(mt) + " " + br
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

          /*IconButton {
              id: stopIcon
              icon.source: "image://theme/icon-m-reset"
              onClicked: stop()
          }*/

       }
    }
}

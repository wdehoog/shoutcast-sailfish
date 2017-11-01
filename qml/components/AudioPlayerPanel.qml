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

    property string genreName: ""
    property string stationName: ""
    property string streamURL: ""
    property string logoURL: ""

    property string defaultImageSource : "image://theme/icon-m-music"
    property string playIconSource : "image://theme/icon-m-play"

    property string titleText: stationName
    property string durationText: ""
    property string metaText: genreName

    property string streamMetaText1: stationName
    property string streamMetaText2: ""


    onLogoURLChanged: cover.imageSource = logoURL.length > 0 ? logoURL : defaultImageSource

    Connections {
        target: app
        onStationChanged: {
            stationName = name
            streamURL = stream ? stream : ""
            logoURL = logo ? logo : ""

            app.audio.source = streamURL
        }

        onAudioBufferFull: {
            play()
            updateIcons()
        }

        onPlayRequested: play()
        onPauseRequested: pause()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            var title = audio.metaData.title
            if(title !== undefined) {
                streamMetaText1 = title
                streamMetaText2 = app.audio.metaData.publisher

                var metaData = {}
                metaData['title'] = title
                metaData['artist'] = app.audio.metaData.publisher
                app.mprisPlayer.metaData = metaData

                console.log("meta1: " + streamMetaText1)
                console.log("meta2: " + streamMetaText2)
            } else {
                streamMetaText1 = stationName ? stationName : ""
                streamMetaText2 = metaText ? metaText : ""
                app.mprisPlayer.metaData = {}
            }
        }
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
            source: logoURL.length > 0 ? logoURL : defaultImageSource
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
                text: streamMetaText1
            }
            Text {
                id: m2
                x: Theme.paddingSmall
                width: parent.width- Theme.paddingSmall
                anchors.right: parent.right
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: streamMetaText2 //lc + " " + Shoutcast.getAudioType(mt) + " " + br
            }

        }

        Row {
          id: playerButtons

          anchors.verticalCenter: parent.verticalCenter
          //spacing: Theme.paddingSmall
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

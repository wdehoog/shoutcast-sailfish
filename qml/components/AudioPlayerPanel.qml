//pragma Singleton
import QtQuick 2.0 
import Sailfish.Silica 1.0
import QtMultimedia 5.5

import "../shoutcast.js" as Shoutcast
import "../"

DockedPanel {
    id: panel

    width: parent.width
    height: Theme.itemSizeMedium + Theme.paddingMedium

    dock: Dock.Bottom
    open: audio.hasAudio

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

    property alias audio: audio

    onLogoURLChanged: cover.imageSource = logoURL.length > 0 ? logoURL : defaultImageSource

    Audio {
        id: audio
        source: streamURL
        autoLoad: true
        autoPlay: false

        //onPlaybackStateChanged: refreshTransportState()
        //onSourceChanged: refreshTransportState()
        onBufferProgressChanged: {
            if(bufferProgress == 1.0) {
                play()
                updateIcons()
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            var title = audio.metaData.title
            if(title !== undefined) {
                streamMetaText1 = title
                streamMetaText2 = audio.metaData.publisher
                app.mainPage.mpris.metaData = audio.metaData

                var metaData = {}
                metaData['artist'] = audio.metaData.publisher
                metaData['title'] = audio.metaData.title
                app.mainPage.mpris.metaData = metaData
            } else {
                streamMetaText1 = ""
                streamMetaText2 = ""
                app.mainPage.mpris.metaData = {}
            }
        }
    }

    function play() {
        audio.play()
        updateIcons()
    }

    function pause() {
        if(audio.playbackState == Audio.PlayingState) {
            audio.pause()
            updateIcons()
        } else {
            play()
        }
    }

    function stop() {
        audio.stop()
        updateIcons()
    }

    function updateIcons() {
        if(audio.playbackState == Audio.PlayingState) {
            playIconSource = "image://theme/icon-m-pause";
            cover.playIconSource = "image://theme/icon-cover-pause";
        } else {
            playIconSource =  "image://theme/icon-m-play";
            cover.playIconSource = "image://theme/icon-cover-play";
        }
    }

    Row {
        width: parent.width

        Image {
            id: imageItem
            source: logoURL.length > 0 ? logoURL : defaultImageSource
            width: parent.width / 3
            height: width
            fillMode: Image.PreserveAspectFit
        }

        Row {
          id: playerButtons

          anchors.verticalCenter: parent.verticalCenter
          spacing: Theme.paddingMedium
          width: parent.width * 2 / 3
          //height: playIcon.height

          IconButton {
              id: playIcon
              icon.source: playIconSource
              onClicked: pause()
          }
          IconButton {
              id: stopIcon
              icon.source: "image://theme/icon-m-reset"
              onClicked: {
                  stop()
                  //app.stop()
              }
          }

       }
    }
}

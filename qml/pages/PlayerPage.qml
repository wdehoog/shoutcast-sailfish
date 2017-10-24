/*
  Copyright (C) 207 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.5

import "../components"
import "../shoutcast.js" as Shoutcast

Page {
    id: playerPage
    property string genreName: ""
    property string stationName: ""
    property string streamURL: ""
    property string logoURL: ""

    property string defaultImageSource : "image://theme/icon-l-music"
    property string playIconSource : "image://theme/icon-l-play"

    property string titleText: stationName
    property string durationText: ""
    property string metaText: genreName

    property string streamMetaText1: stationName
    property string streamMetaText2: ""

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

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
            if(title === undefined)
                return
            var publisher = audio.metaData.publisher
            streamMetaText1 = title
            streamMetaText2 = publisher
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
            playIconSource = "image://theme/icon-l-pause";
            //cover.playIconSource = "image://theme/icon-cover-pause";
        } else {
            playIconSource =  "image://theme/icon-l-play";
            //cover.playIconSource = "image://theme/icon-cover-play";
        }
    }

    SilicaListView {
        id: listView
        //model: trackListModel
        width: parent.width
        anchors.fill: parent

        header: Column {
            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium

            anchors {
                topMargin: 0
                bottomMargin: Theme.paddingLarge
            }

            Rectangle {
                width: parent.width
                height:Theme.paddingLarge
                opacity: 0
            }

            Row {

                width: parent.width

                /*Rectangle {
                    width: Theme.paddingLarge
                    height: parent.height
                    opacity: 0
                }*/

                Image {
                    id: imageItem
                    source: logoURL.length > 0 ? logoURL : defaultImageSource
                    width: parent.width / 2
                    height: width
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                  id: playerButtons

                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Theme.paddingMedium
                  width: parent.width / 2
                  //height: playIcon.height

                  IconButton {
                      anchors.horizontalCenter: parent.horizontalCenter
                      id: playIcon
                      icon.source: playIconSource
                      onClicked: pause()
                  }

               }
            }

            Rectangle {
                width: parent.width
                height:Theme.paddingMedium
                opacity: 0
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                    color:  Theme.highlightColor
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    text: streamMetaText1
                }
                Text {
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.secondaryHighlightColor
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    text: streamMetaText2
                }
            }

            Separator {
                anchors.left: parent.left
                anchors.right: parent.right
                color: "white"
            }

        } // header

        VerticalScrollDecorator {}

        /*delegate: ListItem {
            id: delegate
            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium

            Column {
                width: parent.width

                Item {
                    width: parent.width
                    height: tt.height

                    Label {
                        id: tt
                        color: currentItem === index ? Theme.highlightColor : Theme.primaryColor
                        textFormat: Text.StyledText
                        truncationMode: TruncationMode.Fade
                        width: parent.width - dt.width
                        text: titleText
                    }

                    Label {
                        id: dt
                        anchors.right: parent.right
                        color: currentItem === index ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: durationText
                    }
                }

                Label {
                    color: currentItem === index ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    textFormat: Text.StyledText
                    truncationMode: TruncationMode.Fade
                    width: parent.width
                    visible: metaText ? metaText.length > 0 : false
                    text: metaText
                }

            }
        }*/
    }
}


/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../shoutcast.js" as Shoutcast

Page {
    id: staionsPage

    property string genreName: ""
    property string genreId: ""
    property int currentItem: -1

    property bool showBusy: false

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    JSONListModel {
        id: stationsModel
        source: Shoutcast.StationSearchBase
                + "?" + Shoutcast.getGenrePart(genreId)
                + "&" + Shoutcast.DevKeyPart
                + "&" + Shoutcast.LimitPart
                + "&" + Shoutcast.QueryFormat
        query: "$..station.*"
        keepQuery: "$..tunein"
        orderField: "lc"
    }

    onGenreIdChanged: showBusy = true

    Connections {
        target: stationsModel
        onLoaded: showBusy = false
    }

    SilicaListView {
        id: genreView
        model: stationsModel.model
        anchors.fill: parent
        anchors {
            topMargin: 0
            bottomMargin: 0
        }

        header: Column {
            id: lvColumn

            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge

            PageHeader {
                id: pHeader
                title: genreName
                BusyIndicator {
                    id: busyThingy
                    parent: pHeader.extraContent
                    anchors.left: parent.left
                    running: showBusy
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        delegate: ListItem {
            id: delegate
            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium

            Column {
                width: parent.width

                Item {
                    width: parent.width
                    height: nameLabel.height

                    Label {
                        id: nameLabel
                        color: Theme.primaryColor
                        textFormat: Text.StyledText
                        truncationMode: TruncationMode.Fade
                        width: parent.width - countLabel.width
                        text: name
                    }
                    Label {
                        id: countLabel
                        anchors.right: parent.right
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: lc + " " + Shoutcast.getAudioType(mt) + " " + br
                    }
                }

                Label {
                    color: currentItem === index ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    textFormat: Text.StyledText
                    truncationMode: TruncationMode.Fade
                    width: parent.width
                    //visible: metaText ? metaText.length > 0 : false
                    text: ct ? ct : qsTr("no track info")
                }
            }

            onClicked: {
                var xhr = new XMLHttpRequest
                var uri = Shoutcast.TuneInBase
                        + stationsModel.keepObject[0]["base-m3u"]
                        + "?" + Shoutcast.getStationPart(model.id)
                xhr.open("GET", uri)
                xhr.onreadystatechange = function() {
                    if(xhr.readyState === XMLHttpRequest.DONE) {
                        var m3u = xhr.responseText;
                        //console.log("Station: \n" + m3u)
                        var streamURL = Shoutcast.extractURLFromM3U(m3u)
                        console.log("URL: \n" + streamURL)
                        if(streamURL.length > 0) {
                            var page = pageStack.nextPage()
                            if(!page)
                                pageStack.pushAttached(app.getPlayerPage(),
                                                       {genreName: genreName,
                                                        stationName: model.name,
                                                        streamURL: streamURL,
                                                        logoURL: model.logo})
                            else {
                                page.genreName = genreName
                                page.stationName = model.name
                                page.streamURL = streamURL
                                page.logoURL = model.logo
                            }
                            pageStack.navigateForward(PageStackAction.Animated)
                        }

                    }
                }
                xhr.send();
            }
        }

    }

//    function loadGenres() {
//        var i
//        for(i=0;i<genresModel.count;i++)
//            console.log(genresModel.model.get(i))
//    }
}

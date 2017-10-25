/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

import "pages"
import "cover"

ApplicationWindow {
    id: app

    initialPage: Component { MainPage { } }
    allowedOrientations: defaultAllowedOrientations

    cover: CoverPage {
        id: cover
    }

    PlayerPage {
        id: playerPage
    }

    function getPlayerPage() {
        return playerPage
    }

    function pause() {
        playerPage.pause()
    }

    function loadStation(stationId, name, logoURL) {
        var xhr = new XMLHttpRequest
        var uri = Shoutcast.TuneInBase
                + stationsModel.keepObject[0]["base-m3u"]
                + "?" + Shoutcast.getStationPart(stationId)
        xhr.open("GET", uri)
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                var m3u = xhr.responseText;
                //console.log("Station: \n" + m3u)
                var streamURL = Shoutcast.extractURLFromM3U(m3u)
                console.log("URL: \n" + streamURL)
                if(streamURL.length > 0) {
                    var page = app.getPlayerPage()
                    page.genreName = genreName
                    page.stationName = name
                    page.streamURL = streamURL
                    page.logoURL = logoURL
                }
            }
        }
        xhr.send();
    }
}


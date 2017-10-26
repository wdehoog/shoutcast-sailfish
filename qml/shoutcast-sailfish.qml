/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

import "pages"
import "cover"

import "shoutcast.js" as Shoutcast

ApplicationWindow {
    id: app
    property alias maxNumberOfResults: max_number_of_results
    property alias mainPage: mainPage
    property alias playerPage: playerPage

    initialPage: mainPage
    allowedOrientations: defaultAllowedOrientations

    cover: CoverPage {
        id: cover
    }

    MainPage {
        id: mainPage
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

    function loadStation(stationId, name, logoURL, tuneinBase) {
        var xhr = new XMLHttpRequest
        var uri = Shoutcast.TuneInBase
                + tuneinBase
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
                    //page.genreName = genreName
                    page.stationName = name
                    page.streamURL = streamURL
                    page.logoURL = logoURL ? logoURL : ""
                }
            }
        }
        xhr.send();
    }

    function loadKeywordSearch(keywordQuery, onDone) {
        var xhr = new XMLHttpRequest
        var uri = Shoutcast.KeywordSearchBase
            + "?" + Shoutcast.DevKeyPart
            + "&" + Shoutcast.getLimitPart(max_number_of_results.value)
            + "&" + Shoutcast.getSearchPart(keywordQuery)
        xhr.open("GET", uri)
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                onDone(xhr.responseText)
            }
        }
        xhr.send();
    }

    function loadTop500(onDone) {
        var xhr = new XMLHttpRequest
        var uri = Shoutcast.Top500Base
                + "?" + Shoutcast.DevKeyPart
                + "&" + Shoutcast.getLimitPart(app.maxNumberOfResults.value)
                + "&" + Shoutcast.QueryFormat
        xhr.open("GET", uri)
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                onDone(xhr.responseText)
            }
        }
        xhr.send();
    }

    ConfigurationValue {
            id: max_number_of_results
            key: "/shoutcast-sailfish/max_number_of_results"
            defaultValue: 200
    }

}


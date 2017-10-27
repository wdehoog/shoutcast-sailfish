/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.dbus 2.0

import "dialogs"
import "pages"
import "cover"

import "shoutcast.js" as Shoutcast

ApplicationWindow {
    id: app

    property alias maxNumberOfResults: max_number_of_results
    property alias mprisPlayerServiceName: mpris_player_servicename
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

    property bool playMPris: true

    function loadStation(stationId, name, mimeType, logoURL, tuneinBase) {
        var xhr = new XMLHttpRequest
        var uri = Shoutcast.TuneInBase
                + tuneinBase
                + "?" + Shoutcast.getStationPart(stationId)
        xhr.open("GET", uri)
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                var m3u = xhr.responseText;
                console.log("Station: \n" + m3u)
                var streamURL = Shoutcast.extractURLFromM3U(m3u)
                console.log("URL: \n" + streamURL)
                if(streamURL.length > 0) {
                    if(!playMPris) {
                        var page = app.getPlayerPage()
                        //page.genreName = genreName
                        page.stationName = name
                        page.streamURL = streamURL
                        page.logoURL = logoURL ? logoURL : ""
                    } else
                        mprisOpenUri(streamURL, mimeType)
                } else {
                    showErrorDialog(qsTr("Failed to retrieve stream URL."))
                    console.log("Error could not find stream URL: \n" + m3u)
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

    function showErrorDialog(text) { //, showCancelAll, cancelAll) {
        var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/ErrorDialog.qml"),
                                    {errorMessageText: text}) //, showCancelAll: showCancelAll});
        /*if(showCancelAll) {
          dialog.accepted.connect(function() {
              if(dialog.cancelAll)
                cancelAll()
          })
        }*/
    }

    function mprisOpenUri(uri, mimeType) {
        mpris.openUri(uri, mimeType)
    }


    function getFileNameParts(url) {
        var matches = url && typeof url.match === "function" && url.match(/\/?([^/.]*)\.?([^/]*)$/);
        if (!matches)
            return null;

        //if (includeExtension && matches.length > 2 && matches[2]) {
        //    return matches.slice(1).join(".");
        //}
        return matches; //matches[1];
    }


    DBusInterface {
        id: mpris

        bus:DBus.SystemBus
        service: "org.mpris.MediaPlayer2" + mpris_player_servicename
        path: "/org/mpris/MediaPlayer2"
        iface: "org.mpris.MediaPlayer2.Player"

        function openUri(uri, mimeType) {
            // dbus-send  --print-reply --session --type=method_call
            // --dest=org.mpris.MediaPlayer2.donnie /org/mpris/MediaPlayer2
            // org.mpris.MediaPlayer2.Player.OpenUri "string:http://....."

            // QT Mpris checks mimetype and uses the file extension so we have to make sure
            // it is there. Maybe then the stream uri becomes invalid. So be it because no
            // mime type will definately not work.
            var fileNameParts = getFileNameParts(uri)
            if(fileNameParts.length <= 2
               || fileNameParts[2].length === 0) {
                // no extension
                uri += "." + Shoutcast.getAudioTypeExtension(mimeType)
                console.log("mpris.openUri added extension to uri: " + uri)
            }

            typedCall('OpenUri', { "type": "s", "value": uri},
                 function(result) {
                     console.log('mpris.openUri call completed with:', result)
                 },
                 function() {
                     console.log('mpris.openUri call failed for: ' + uri)
                 })
        }
    }

    ConfigurationValue {
        id: max_number_of_results
        key: "/shoutcast-sailfish/max_number_of_results"
        defaultValue: 200
    }

    ConfigurationValue {
        id: mpris_player_servicename
        key: "/shoutcast-sailfish/mpris_player_servicename"
        defaultValue: "donnie"
    }
}


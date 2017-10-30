/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.dbus 2.0

import "components"
import "dialogs"
import "pages"
import "cover"

import "shoutcast.js" as Shoutcast
import "Util.js" as Util

ApplicationWindow {
    id: app

    property string mprisServiceName: "shoutcast-sailfish"
    property alias maxNumberOfResults: max_number_of_results
    property alias mprisPlayerServiceName: mpris_player_servicename
    property alias playerType: player_type
    property alias mainPage: mainPage
    property alias playerPage: playerPage
    property alias dbus: dbus
    property alias playerPanel: dockedPlayerPanel

    initialPage: mainPage
    allowedOrientations: defaultAllowedOrientations

    anchors.bottomMargin: dockedPlayerPanel.visibleSize
    //clip: dockedPlayerPanel.expanded

    cover: CoverPage {
        id: cover
    }

    AudioPlayerPanel {
        id: dockedPlayerPanel
    }

    MainPage {
        id: mainPage
    }

    PlayerPage {
        id: playerPage
    }

    function getAudio() {
        return getPlayerPage().audio
    }

    function getPlayerPage() {
        return playerPanel //Page
    }

    function pause() {
        getPlayerPage().pause()
    }

    function play() {
        getPlayerPage().play()
    }

    //function stop() {
    //
    //}

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
                    switch(playerType.value) {
                    case 1:
                        mprisOpenUri(streamURL, mimeType)
                        break
                    case 0:
                    default:
                        var page = app.getPlayerPage()
                        //page.genreName = genreName
                        page.stationName = name
                        page.streamURL = streamURL
                        page.logoURL = logoURL ? logoURL : ""
                        break
                    }
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

    function showMessageDialog(title, text) {
        var dialog = pageStack.push(Qt.resolvedUrl("dialogs/ErrorDialog.qml"),
                                    {titleText: title, errorMessageText: text})
    }

    function showErrorDialog(text) { //, showCancelAll, cancelAll) {
        var dialog = pageStack.push(Qt.resolvedUrl("dialogs/ErrorDialog.qml"),
                                    {errorMessageText: text}) //, showCancelAll: showCancelAll});
        /*if(showCancelAll) {
          dialog.accepted.connect(function() {
              if(dialog.cancelAll)
                cancelAll()
          })
        }*/
    }

    function getAppIconSource() {
        var iconSize = Theme.iconSizeExtraLarge
        return getAppIconSource2(iconSize)
    }

    function getAppIconSource2(iconSize) {
        if (iconSize < 108)
            iconSize = 86
        else if (iconSize < 128)
            iconSize = 108
        else if (iconSize < 256)
            iconSize = 128
        else
            iconSize = 256

        return "/usr/share/icons/hicolor/" + iconSize + "x" + iconSize + "/apps/shoutcast-sailfish.png"
    }

    function mprisOpenUri(uri, mimeType) {
        mpris.openUri(uri, mimeType)
    }


    /*function getFileNameParts(url) {
        var matches = url && typeof url.match === "function" && url.match(/\/?([^/.]*)\.?([^/]*)$/);
        if(!matches)
            return null;
        return matches;
    }*/

    DBusInterface {
        id: mpris

        bus:DBus.SessionBus
        service: "org.mpris.MediaPlayer2." + mpris_player_servicename.value
        path: "/org/mpris/MediaPlayer2"
        iface: "org.mpris.MediaPlayer2.Player"

        function openUri(uri, mimeType) {
            // dbus-send  --print-reply --session --type=method_call
            // --dest=org.mpris.MediaPlayer2.donnie /org/mpris/MediaPlayer2
            // org.mpris.MediaPlayer2.Player.OpenUri "string:http://....."

            typedCall("OpenUri", { "type": "s", "value": uri},
                 function() {
                     console.log("mpris.openUri call completed for: " + uri)
                 },
                 function() {
                     console.log("mpris.openUri call failed for: " + uri)
                     showErrorDialog("Failed to open uri using Mpris: " + uri)
                 })
        }

    }

    // dbus-send  --print-reply --session --type=method_call
    // --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep -i mpris
    DBusInterface {
        id: dbus

        bus:DBus.SessionBus
        service: "org.freedesktop.DBus"
        path: "/org/freedesktop/DBus"
        iface: "org.freedesktop.DBus"

        function getServices(filter, callback) {
            typedCall('ListNames', undefined,
                 function(result) {
                     //console.log('dbus.getServices call completed with:', result)
                     var filteredServices = []
                     for(var i=0;i<result.length;i++) {
                         var index = result[i].indexOf(filter)
                         if(index > -1)
                             filteredServices.push(result[i].substring(filter.length))
                     }
                     if(callback)
                        callback(filteredServices)
                 },
                 function() {
                     console.log('dbus.getServices call failed')
                 })
        }
        //Component.onCompleted: getServices()
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

    // 0: local player (QT Audio), 1: Mpris openUri
    ConfigurationValue {
        id: player_type
        key: "/shoutcast-sailfish/player_type"
        defaultValue: 0
    }
}


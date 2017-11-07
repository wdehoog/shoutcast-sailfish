/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.dbus 2.0
import QtMultimedia 5.5
import org.nemomobile.mpris 1.0
import org.nemomobile.connectivity 1.0


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
    property alias mimeTypeFilter: mime_type_filter
    property alias playerType: player_type
    property alias scrapeWhenNoData: scrape_when_no_data

    property alias mainPage: mainPage
    //property alias playerPage: playerPage
    property alias dbus: dbus
    property alias audio: audio
    property alias mprisDBus: mprisDBus
    property alias mprisPlayer: mprisPlayer

    initialPage: mainPage
    allowedOrientations: defaultAllowedOrientations

    cover: CoverPage {
        id: cover
    }

    signal audioBufferFull()
    //signal playbackStateChanged()

    Audio {
        id: audio

        autoLoad: true
        autoPlay: false

        //onPlaybackStateChanged: app.playbackStateChanged()
        //onSourceChanged: refreshTransportState()
        onBufferProgressChanged: {
            if(bufferProgress == 1.0)
                audioBufferFull()
        }
        onError: {
            console.log("Audio Player:" + errorString)
            console.log("source: " + source)
            showErrorDialog(qsTr("Audio Player:") + "\n\n" + errorString)
        }
    }

    MainPage {
        id: mainPage
    }

    property string logoURL: ""
    onLogoURLChanged: cover.imageSource = logoURL.length > 0 ? logoURL : cover.defaultImageSource

    signal stationChanged(var stationInfo)

    onStationChanged: {
        app.stationName = stationInfo.name
        app.genreName = stationInfo.genre
        app.streamMetaText1 = stationInfo.name + " - " + stationInfo.lc + " " + Shoutcast.getAudioType(stationInfo.mt) + " " + stationInfo.br
        app.streamMetaText2 = (stationInfo.genre ? (stationInfo.genre + " - ") : "") + stationInfo.ct
        app.logoURL = stationInfo.logo ? stationInfo.logo : ""
        app.audio.source = stationInfo.stream
    }

    function loadStation(stationId, info, tuneinBase) {
        _loadStation(stationId, info, tuneinBase, 1)
    }

    function _loadStation(stationId, info, tuneinBase, retryCount) {
        var m3uBase = tuneinBase["base-m3u"]
        var plsBase = tuneinBase["base"]

        if(!m3uBase && !plsBase) {
            showErrorDialog(qsTr("Don't know how to retrieve playlist."))
            console.log("Don't know how to retrieve playlist.: \n" + JSON.stringify(tuneinBase))
        }

        var xhr = new XMLHttpRequest
        var playlistUri = Shoutcast.TuneInBase
                + (retryCount > 0 ? m3uBase : plsBase)
                + "?" + Shoutcast.getStationPart(stationId)
        xhr.open("GET", playlistUri)
        //xhr.withCredentials = true
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                var playlist = xhr.responseText;
                console.log("Station: \n" + playlist)
                var streamURL
                if(retryCount > 0)
                    streamURL = Shoutcast.extractURLFromM3U(playlist)
                else
                    streamURL = Shoutcast.extractURLFromPLS(playlist)
                console.log("URL: \n" + streamURL)
                if(streamURL.length > 0) {
                    switch(playerType.value) {
                    case 1:
                        mprisOpenUri(streamURL, info.mt)
                        break
                    case 0:
                    default:
                        info.stream = streamURL
                        stationChanged(info)
                        break
                    }
                } else {
                    if(retryCount > 0) {
                        _loadStation(stationId, info, tuneinBase, retryCount - 1)
                        console.log("Error could not find stream URL. Will retry.\n" + playlistUri + "\n" + playlist)
                    } else {
                        console.log("Error could not find stream URL. Will retry again.\n" + playlistUri + "\n" + playlist + "\n")
                        Shoutcast.loadStationStream(stationId, function(streamURL) {
                            if(streamURL.length === 0 || streamURL === "\"\"") {
                                showErrorDialog(qsTr("Failed to retrieve stream URL."))
                                console.log("Error could not find stream URL: \n" + playlistUri + "\n" + playlist + "\n")
                            } else {
                                info.stream = streamURL
                                stationChanged(info)
                            }
                        })
                    }
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
        if(mimeTypeFilter.value === 1)
            uri += "&" + Shoutcast.getAudioTypeFilterPart("audio/mpeg")
        else if(mimeTypeFilter.value === 2)
            uri += "&" + Shoutcast.getAudioTypeFilterPart("audio/aacp")
        uri += "&" + Shoutcast.getSearchPart(keywordQuery)
        //console.log("loadKeywordSearch: " + uri)
        xhr.open("GET", uri)
        //xhr.withCredentials = true
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
        if(mimeTypeFilter.value === 1)
            uri += "&" + Shoutcast.getAudioTypeFilterPart("audio/mpeg")
        else if(mimeTypeFilter.value === 2)
            uri += "&" + Shoutcast.getAudioTypeFilterPart("audio/aacp")
        xhr.open("GET", uri)
        //xhr.withCredentials = true
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                onDone(xhr.responseText)
            }
        }
        xhr.send();
    }

    function getSearchNowPlayingURI(nowPlayingQuery) {
        if(nowPlayingQuery.length === 0)
            return ""
        var uri = Shoutcast.NowPlayingSearchBase
                  + "?" + Shoutcast.DevKeyPart
                  + "&" + Shoutcast.QueryFormat
                  + "&" + Shoutcast.getLimitPart(app.maxNumberOfResults.value)
        if(mimeTypeFilter.value === 1)
            uri += "&" + Shoutcast.getAudioTypeFilterPart("audio/mpeg")
        else if(mimeTypeFilter.value === 2)
            uri += "&" + Shoutcast.getAudioTypeFilterPart("audio/aacp")
        uri += "&" + Shoutcast.getPlayingPart(nowPlayingQuery)
        return uri
    }

    function getStationByGenreURI(genreId) {
      var uri = Shoutcast.StationSearchBase
                    + "?" + Shoutcast.getGenrePart(genreId)
                    + "&" + Shoutcast.DevKeyPart
                    + "&" + Shoutcast.getLimitPart(app.maxNumberOfResults.value)
                    + "&" + Shoutcast.QueryFormat
        if(mimeTypeFilter.value === 1)
            uri += "&" + Shoutcast.getAudioTypeFilterPart("audio/mpeg")
        else if(mimeTypeFilter.value === 2)
            uri += "&" + Shoutcast.getAudioTypeFilterPart("audio/aacp")
        return uri
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
        mprisDBus.openUri(uri, mimeType)
    }


    /*function getFileNameParts(url) {
        var matches = url && typeof url.match === "function" && url.match(/\/?([^/.]*)\.?([^/]*)$/);
        if(!matches)
            return null;
        return matches;
    }*/

    property string stationName: ""
    property string genreName: ""
    property string metaText: genreName
    property string streamMetaText1: stationName
    property string streamMetaText2: ""

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            var title = audio.metaData.title
            var metaData
            if(title !== undefined) {
                streamMetaText1 = title
                streamMetaText2 = app.audio.metaData.publisher

                metaData = {}
                metaData['title'] = title
                metaData['artist'] = app.audio.metaData.publisher
                mprisPlayer.metaData = metaData

                cover.metaText = streamMetaText2
            } else {

                //streamMetaText1 = stationName ? stationName : ""
                //streamMetaText2 = metaText ? metaText : ""

                metaData = {}
                metaData['title'] = streamMetaText1
                metaData['artist'] = stationName
                mprisPlayer.metaData = metaData

                cover.metaText = stationName
            }
            //console.log("streamMetaText1: " + streamMetaText1)
            //console.log("streamMetaText2: " + streamMetaText2)
        }
    }

    onAudioBufferFull: play()
    onPlayRequested: play()
    onPauseRequested: pause()

    function play() {
        audio.play()
    }

    function pause() {
        if(isPlayer) {
            if(audio.playbackState === Audio.PlayingState)
                audio.pause()
            else
                play()
        } else
            mprisDBus.playPause()
    }

    function prev() {
        previousRequested()
    }

    function next() {
        nextRequested()
    }

    signal pauseRequested()
    signal playRequested()
    signal nextRequested()
    signal previousRequested()

    property bool isPlayer: player_type.value === 0

    Connections {
        target: app.audio

        onPlaybackStateChanged: {
            var status

            if(audio.playbackState === Audio.PlayingState)
                status = Mpris.Playing
            else if(audio.playbackState === Audio.StoppedState)
                status = Mpris.Stopped
            else
                status = Mpris.Paused

            // it seems that in order to use the play button on the Lock screen
            // when canPlay is true so should canPause be.
            mprisPlayer.canPlay = isPlayer && status !== Mpris.Playing
            mprisPlayer.canPause = isPlayer && status !== Mpris.Stopped
            mprisPlayer.playbackStatus = status

            //console.log("onPlaybackStateChanged canPlay="+mprisPlayer.canPlay+", canPause="+mprisPlayer.canPause)
        }
    }

    MprisPlayer {
        id: mprisPlayer
        serviceName: mprisServiceName

        property var metaData

        identity: qsTrId("Shoutcast for SailfishOS")

        canControl: isPlayer

        // canPlay and canPause are handled in onPlaybackStateChanged above since there
        // were binding loop problems
        canPause: false
        canPlay: false

        canGoNext: isPlayer && pageStack.currentPage.canGoNext
                   ? pageStack.currentPage.canGoNext : false

        canGoPrevious: isPlayer && pageStack.currentPage.canGoPrevious
                       ? pageStack.currentPage.canGoPrevious : false

        canSeek: false

        playbackStatus: Mpris.Stopped

        onPauseRequested: app.pauseRequested()

        onPlayRequested: app.playRequested()

        onPlayPauseRequested: app.pauseRequested()

        onNextRequested: app.nextRequested()

        onPreviousRequested: app.previousRequested()

        onMetaDataChanged: {
            var metadata = {}

            if (metaData && 'artist' in metaData)
                metadata[Mpris.metadataToString(Mpris.Artist)] = [metaData['artist']] // List of strings
            if (metaData && 'title' in metaData)
                metadata[Mpris.metadataToString(Mpris.Title)] = metaData['title'] // String

            mprisPlayer.metadata = metadata
        }
    }

    DBusInterface {
        id: mprisDBus

        bus:DBus.SessionBus
        service: "org.mpris.MediaPlayer2." + mpris_player_servicename.value
        path: "/org/mpris/MediaPlayer2"
        iface: "org.mpris.MediaPlayer2.Player"

        function play() {
            // dbus-send  --print-reply --session --type=method_call
            // --dest=org.mpris.MediaPlayer2.donnie /org/mpris/MediaPlayer2
            // org.mpris.MediaPlayer2.Player.Play
            typedCall("Play", {}, undefined, function() {
                console.log("mpris.Play call failed.")
            })
        }

        function pause() {
            // dbus-send  --print-reply --session --type=method_call
            // --dest=org.mpris.MediaPlayer2.donnie /org/mpris/MediaPlayer2
            // org.mpris.MediaPlayer2.Player.Pause
            typedCall("Pause", {}, undefined, function() {
                console.log("mpris.Pause call failed.")
            })
        }

        function playPause() {
            // dbus-send  --print-reply --session --type=method_call
            // --dest=org.mpris.MediaPlayer2.donnie /org/mpris/MediaPlayer2
            // org.mpris.MediaPlayer2.Player.PlayPause
            typedCall("PlayPause", {}, undefined, function() {
                console.log("mpris.PlayPause call failed.")
            })
        }

        function next() {
            // dbus-send  --print-reply --session --type=method_call
            // --dest=org.mpris.MediaPlayer2.donnie /org/mpris/MediaPlayer2
            // org.mpris.MediaPlayer2.Player.Next
            typedCall("Next", {}, undefined, function() {
                console.log("mpris.Next call failed.")
            })
        }

        function previous() {
            // dbus-send  --print-reply --session --type=method_call
            // --dest=org.mpris.MediaPlayer2.donnie /org/mpris/MediaPlayer2
            // org.mpris.MediaPlayer2.Player.Previous
            typedCall("Previous", {}, undefined, function() {
                console.log("mpris.Previous call failed.")
            })
        }

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

    property bool connectedToNetwork: false
    ConnectionHelper {
         id: connectionHelper
         onNetworkConnectivityEstablished: {
             connectedToNetwork = true
         }
         onNetworkConnectivityUnavailable: {
             connectedToNetwork = false
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

    // 0: local player (QT Audio), 1: Mpris openUri
    ConfigurationValue {
        id: player_type
        key: "/shoutcast-sailfish/player_type"
        defaultValue: 0
    }

    // 0: no filter, 1: only audio/mpeg, 2: only audio/aacp
    ConfigurationValue {
        id: mime_type_filter
        key: "/shoutcast-sailfish/mime_type_filter"
        defaultValue: 1
    }

    // true: try to scrape, false: do not scrape
    ConfigurationValue {
        id: scrape_when_no_data
        key: "/shoutcast-sailfish/scrape_when_no_data"
        defaultValue: true
    }

}


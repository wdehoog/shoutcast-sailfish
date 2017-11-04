/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../shoutcast.js" as Shoutcast

Page {
    id: stationsPage
    objectName: "StationsPage"

    property string genreName: ""
    property string genreId: ""
    property int currentItem: -1
    property bool canGoNext: currentItem < (stationsModel.count-1)
    property bool canGoPrevious: currentItem > 0

    property bool showBusy: false
    property var tuneinBase: ({})

    allowedOrientations: Orientation.All

    JSONListModel {
        id: stationsModel
        source: Shoutcast.StationSearchBase
                + "?" + Shoutcast.getGenrePart(genreId)
                + "&" + Shoutcast.DevKeyPart
                + "&" + Shoutcast.getLimitPart(app.maxNumberOfResults.value)
                + "&" + Shoutcast.QueryFormat
        query: "$..station.*"
        keepQuery: "$..tunein"
        orderField: "lc"
    }

    onGenreIdChanged: showBusy = true

    Connections {
        target: stationsModel
        onLoaded: {
            showBusy = false
            currentItem = -1
            tuneinBase = {}
            var b = stationsModel.keepObject[0]["base"]
            if(b)
                tuneinBase["base"] = b
            b = stationsModel.keepObject[0]["base-m3u"]
            if(b)
                tuneinBase["base-m3u"] = b
            b = stationsModel.keepObject[0]["base-xspf"]
            if(b)
                tuneinBase["base-xspf"] = b
        }
    }

    function reload() {
        showBusy = true
        stationsModel.refresh()
    }

    property alias playerPanel: audioPanel
    AudioPlayerPanel {
        id: audioPanel

        page: stationsPage

        onPrevious: {
            if(canGoPrevious) {
                currentItem--
                var item = stationsModel.model.get(currentItem)
                if(item)
                    app.loadStation(item.id, Shoutcast.createInfo(item), tuneinBase)
            }
        }

        onNext: {
            if(canGoNext) {
                currentItem++
                var item = stationsModel.model.get(currentItem)
                if(item)
                     app.loadStation(item.id, Shoutcast.createInfo(item), tuneinBase)
            }
        }
    }

    SilicaListView {
        id: genreView
        model: stationsModel.model
        anchors.fill: parent
        anchors.topMargin: 0

        anchors.bottomMargin: playerPanel.visibleSize
        clip: playerPanel.expanded

        PullDownMenu {
            MenuItem {
                text: qsTr("Reload")
                onClicked: reload()
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Reload")
                onClicked: reload()
            }
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
            height: stationListItemView.height
            x: Theme.paddingMedium

            StationListItemView {
                id: stationListItemView
            }

            onClicked: {
                app.loadStation(model.id, Shoutcast.createInfo(model), tuneinBase)
                currentItem = index
            }
        }

    }

}


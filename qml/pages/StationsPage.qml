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
    property int navDirection: 0 // 0: none, -x: prev, +x: next

    property bool showBusy: false
    property var tuneinBase: ({})

    allowedOrientations: Orientation.All

    JSONListModel {
        id: stationsModel
        source: app.getStationByGenreURI(genreId)
        query: "$..station"
        keepQuery: "$..tunein"
        orderField: "lc"
    }

    onGenreIdChanged: {
        showBusy = true
        stationsModel.model.clear()
    }

    /*onStatusChanged: {
        if(status === PageStatus.Active)
            reload()
    }*/

    function loadingDone() {
        if(stationsModel.model.count === 0) {
            app.showErrorDialog(qsTr("SHOUTcast server returned no Stations"))
            console.log("SHOUTcast server returned no Stations")
        } else
            currentItem = app.findStation(app.stationId, stationsModel.model)
    }

    Connections {
        target: stationsModel
        onLoaded: {
            showBusy = false
            currentItem = -1
            tuneinBase = {}
            if(stationsModel.model.count === 0
               && app.scrapeWhenNoData.value) {
                Shoutcast.loadStationsAnotherWay(genreName, function(stations, tunein) {
                    for(var i=0;i<stations.length;i++)
                       stationsModel.model.append(stations[i])
                    tuneinBase = tunein
                    loadingDone()
                })
            } else {
                var b = stationsModel.keepObject[0]["base"]
                if(b)
                    tuneinBase["base"] = b
                b = stationsModel.keepObject[0]["base-m3u"]
                if(b)
                    tuneinBase["base-m3u"] = b
                b = stationsModel.keepObject[0]["base-xspf"]
                if(b)
                    tuneinBase["base-xspf"] = b
                loadingDone()
            }
        }
        onTimeout: {
            app.showErrorDialog(qsTr("SHOUTcast server did not respond"))
            console.log("SHOUTcast server did not respond")
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
                navDirection = - 1
                var item = stationsModel.model.get(currentItem + navDirection)
                if(item)
                    app.loadStation(item.id, Shoutcast.createInfo(item), tuneinBase)
            }
        }

        onNext: {
            if(canGoNext) {
                navDirection = 1
                var item = stationsModel.model.get(currentItem + navDirection)
                if(item)
                     app.loadStation(item.id, Shoutcast.createInfo(item), tuneinBase)
            }
        }
    }

    Connections {
        target: app
        onStationChanged: {
            navDirection = 0
            // station has changed look for the new current one
            currentItem = app.findStation(stationInfo.id, stationsModel.model)
        }
        onStationChangeFailed: {
            if(navDirection !== 0)
                navDirection = app.navToPrevNext(currentItem, navDirection, stationsModel.model, tuneinBase)
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
                text: qsTr("Show Player")
                onClicked: audioPanel.show()
            }
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
            MenuItem {
                text: qsTr("Show Player")
                onClicked: audioPanel.show()
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
            contentHeight: childrenRect.height

            StationListItemView {
                id: stationListItemView
            }

            onClicked: app.loadStation(model.id, Shoutcast.createInfo(model), tuneinBase)
        }

        VerticalScrollDecorator {}

        Label {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            visible: parent.count == 0
            text: qsTr("No stations found")
            color: Theme.secondaryColor
        }
    }

}


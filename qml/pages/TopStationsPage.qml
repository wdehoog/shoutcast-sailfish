/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0

import "../components"
import "../shoutcast.js" as Shoutcast

Page {
    id: top500Page
    objectName: "TopStationsPage"

    property int currentItem: -1

    property bool showBusy: false
    property var tuneinBase: ({})
    property bool canGoNext: currentItem < (top500Model.count-1)
    property bool canGoPrevious: currentItem > 0

    allowedOrientations: Orientation.All

    ListModel {
        id: stationsModel
    }

    XmlListModel {
        id: top500Model
        query: "/stationlist/station"
        XmlRole { name: "name"; query: "string(@name)" }
        XmlRole { name: "mt"; query: "string(@mt)" }
        XmlRole { name: "id"; query: "@id/number()" }
        XmlRole { name: "br"; query: "@br/number()" }
        XmlRole { name: "genre"; query: "string(@genre)" }
        XmlRole { name: "ct"; query: "string(@ct)" }
        XmlRole { name: "lc"; query: "@lc/number()" }
        XmlRole { name: "logo"; query: "string(@logo)" }
        XmlRole { name: "genre2"; query: "string(@genre2)" }
        XmlRole { name: "genre3"; query: "string(@genre3)" }
        XmlRole { name: "genre4"; query: "string(@genre4)" }
        XmlRole { name: "genre5"; query: "string(@genre5)" }
        onStatusChanged: {
            if (status !== XmlListModel.Ready)
                return
            showBusy = false
        }
    }

    XmlListModel {
        id: tuneinModel
        query: "/stationlist/tunein"
        XmlRole{ name: "base"; query: "@base/string()" }
        XmlRole{ name: "base-m3u"; query: "@base-m3u/string()" }
        XmlRole{ name: "base-xspf"; query: "@base-xspf/string()" }
        onStatusChanged: {
            if (status !== XmlListModel.Ready)
                return
            tuneinBase = {}
            if(tuneinModel.count > 0) {
                var b = tuneinModel.get(0)["base"]
                if(b)
                    tuneinBase["base"] = b
                b = tuneinModel.get(0)["base-m3u"]
                if(b)
                    tuneinBase["base-m3u"] = b
                b = tuneinModel.get(0)["base-xspf"]
                if(b)
                    tuneinBase["base-xspf"] = b
            }
        }
    }

    function reload() {
        showBusy = true
        currentItem = -1
        app.loadTop500(function(xml) {
            //console.log(xml)
            top500Model.xml = xml
            top500Model.reload()
            tuneinModel.xml = xml
            tuneinModel.reload()
        })
    }

    Component.onCompleted: reload()


    property alias playerPanel: audioPanel
    AudioPlayerPanel {
        id: audioPanel

        page: top500Page

        onPrevious: {
            if(canGoPrevious) {
                currentItem--
                var item = top500Model.get(currentItem)
                if(item)
                    app.loadStation(item.id, Shoutcast.createInfo(item), tuneinBase)
            }
        }

        onNext: {
            if(canGoNext) {
                currentItem++
                var item = top500Model.get(currentItem)
                if(item)
                     app.loadStation(item.id, Shoutcast.createInfo(item), tuneinBase)
            }
        }
    }

    SilicaListView {
        id: genreView
        model: top500Model
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
                title: qsTr("Top 500")
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


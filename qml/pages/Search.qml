/**
 * Donnie. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


import QtQuick 2.0

import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0

import org.nemomobile.configuration 1.0

import "../components"
import "../shoutcast.js" as Shoutcast

Page {
    id: searchPage
    objectName: "SearchPage"

    property bool keepSearchFieldFocus: true
    property bool showBusy: false;
    property string searchString: ""
    property int startIndex: 0
    property int totalCount
    property var searchResults
    property var searchCapabilities: []
    property var scMap: []
    property string groupByField: ""
    property int searchInType: 0
    property var tuneinBase: ({})

    property int currentItem: -1
    property bool canGoNext: currentItem < (searchModel.count-1)
    property bool canGoPrevious: currentItem > 0
    property int navDirection: 0 // 0: none, -x: prev, +x: next

    /*onSearchStringChanged: {
        typeDelay.restart()
    }

    Timer {
        id: typeDelay
        interval: 1000
        running: false
        repeat: false
        onTriggered: refresh()
    }*/

    onSearchInTypeChanged: {
        refresh()
    }

    function refresh() {
        if(searchString.length >= 1) {
            if(searchInType === 0)
                performNowPlayingSearch(searchString)
            else
                performKeywordSearch(searchString)
        }
    }

    property string _prevSearchString: ""
    function performNowPlayingSearch(searchString) {
        if(searchString === "")
            return
        showBusy = true
        searchModel.clear()
        if(searchString === _prevSearchString)
            nowPlayingModel.refresh()
        else {
            nowPlayingModel.source = app.getSearchNowPlayingURI(searchString)
            _prevSearchString = searchString
        }
    }

    JSONListModel {
        id: nowPlayingModel
        source: ""
        query: "$..station"
        keepQuery: "$..tunein"
    }

    Connections {
        target: nowPlayingModel
        onLoaded: {
            console.log("new results: "+nowPlayingModel.model.count)
            var i
            currentItem = -1
            for(i=0;i<nowPlayingModel.model.count;i++)
                searchModel.append(nowPlayingModel.model.get(i))
            tuneinBase = {}
            if(nowPlayingModel.keepObject.length > 0) {
                var b = nowPlayingModel.keepObject[0]["base"]
                if(b)
                    tuneinBase["base"] = b
                b = nowPlayingModel.keepObject[0]["base-m3u"]
                if(b)
                    tuneinBase["base-m3u"] = b
                b = nowPlayingModel.keepObject[0]["base-xspf"]
                if(b)
                    tuneinBase["base-xspf"] = b
            }
            showBusy = false
            if(searchModel.count > 0)
                currentItem = app.findStation(app.stationId, searchModel)
        }
        onTimeout: {
            showBusy = false
            app.showErrorDialog(qsTr("SHOUTcast server did not respond"))
            console.log("SHOUTcast server did not respond")
        }
    }

    function performKeywordSearch(searchString) {
        if(searchString.length === 0)
            return
        showBusy = true
        searchModel.clear()
        app.loadKeywordSearch(searchString, function(xml) {
            //console.log("onDone: " + xml)
            if(keywordModel.xml === xml) {
                // same data so we in theory we are done
                // but the list might have contained data from 'Now Playing'
                // so we reload().
                keywordModel.reload()
                tuneinModel.reload()
            } else {
                keywordModel.xml = xml
                tuneinModel.xml = xml
            }
        }, function() {
            // timeout
            showBusy = false
            app.showErrorDialog(qsTr("SHOUTcast server did not respond"))
            console.log("SHOUTcast server did not respond")
        })
    }

    XmlListModel {
        id: keywordModel
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
            var i
            currentItem = -1
            for(i=0;i<count;i++)
                searchModel.append(get(i))
            showBusy = false
            if(searchModel.count > 0)
                currentItem = app.findStation(app.stationId, searchModel)
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

    ListModel {
        id: searchModel
    }

    property alias playerPanel: audioPanel
    AudioPlayerPanel {
        id: audioPanel
        page: searchPage

        onPrevious: {
            if(canGoPrevious) {
                navDirection = - 1
                var item = searchModel.get(currentItem + navDirection)
                if(item)
                    app.loadStation(item.id, Shoutcast.createInfo(item), tuneinBase)
            }
        }

        onNext: {
            if(canGoNext) {
                navDirection = 1
                var item = searchModel.get(currentItem + navDirection)
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
            currentItem = app.findStation(stationInfo.id, searchModel)
        }
        onStationChangeFailed: {
            if(navDirection !== 0)
                navDirection = app.navToPrevNext(currentItem, navDirection, searchModel, tuneinBase)
        }
    }

    SilicaListView {
        id: listView
        model: searchModel
        anchors.fill: parent
        anchors.topMargin: 0

        anchors.bottomMargin: playerPanel.visibleSize
        clip: playerPanel.expanded

        header: Column {
            id: lvColumn

            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge

            PageHeader {
                id: pHeader
                width: parent.width
                title: qsTr("Search")
                BusyIndicator {
                    id: busyThingy
                    parent: pHeader.extraContent
                    anchors.left: parent.left
                    running: showBusy;
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }

            PullDownMenu {
                MenuItem {
                    text: qsTr("Show Player")
                    onClicked: audioPanel.show()
                }
            }

            PushUpMenu {
                MenuItem {
                    text: qsTr("Show Player")
                    onClicked: audioPanel.show()
                }
            }

            SearchField {
                id: searchField
                width: parent.width
                placeholderText: qsTr("Search text")
                Binding {
                    target: searchPage
                    property: "searchString"
                    value: searchField.text.toLowerCase().trim()
                }
                EnterKey.onClicked: refresh()
            }

            ComboBox {
                id: searchIn
                width: parent.width
                label: qsTr("Search in")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Now Playing")
                        onClicked: searchInType = 0
                    }
                    MenuItem {
                        text: qsTr("Keyword")
                        onClicked: searchInType = 1
                    }
                }
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

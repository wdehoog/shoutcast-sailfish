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
    property string nowPlayingQuery: ""
    property string keywordQuery: ""
    property int searchInType: 0
    property var tuneinBase: ({})

    property int currentItem: -1
    property bool canGoNext: currentItem < (searchModel.count-1)
    property bool canGoPrevious: currentItem > 0

    onSearchStringChanged: {
        typeDelay.restart()
    }

    onSearchInTypeChanged: {
        refresh()
    }

    Timer {
        id: typeDelay
        interval: 1000
        running: false
        repeat: false
        onTriggered: refresh()
    }

    function refresh() {
        if(searchString.length >= 2) {
            showBusy = true
            if(searchInType === 0)
                nowPlayingQuery = searchString
            else
                keywordQuery = searchString
        }
    }

    JSONListModel {
        id: nowPlayingModel
        source: nowPlayingQuery.length == 0 ? "" : (Shoutcast.NowPlayingSearchBase
                + "?" + Shoutcast.DevKeyPart
                + "&" + Shoutcast.QueryFormat
                + "&" + Shoutcast.getLimitPart(app.maxNumberOfResults.value)
                + "&" + Shoutcast.getPlayingPart(nowPlayingQuery))
        query: "$..station.*"
        keepQuery: "$..tunein"
    }

    Connections {
        target: nowPlayingModel
        onLoaded: {
            var i
            currentItem = -1
            searchModel.clear()
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
            nowPlayingQuery = ""
            showBusy = false
        }
    }

    onKeywordQueryChanged: {
        if(keywordQuery.length === 0)
            return
        app.loadKeywordSearch(keywordQuery, function(xml) {
            keywordModel.xml = xml
            tuneinModel.xml = xml
        })
    }

    XmlListModel {
        id: keywordModel
        query: "/stationlist/station"
        XmlRole { name: "name"; query: "@name/string()" }
        XmlRole { name: "mt"; query: "@mt/string()" }
        XmlRole { name: "id"; query: "@id/number()" }
        XmlRole { name: "br"; query: "@br/number()" }
        XmlRole { name: "genre"; query: "@genre/string()" }
        XmlRole { name: "ct"; query: "@ct/string()" }
        XmlRole { name: "lc"; query: "@lc/number()" }
        XmlRole { name: "logo"; query: "@logo/string()" }
        onStatusChanged: {
            if (status !== XmlListModel.Ready)
                return
            var i
            currentItem = -1
            searchModel.clear()
            for(i=0;i<count;i++)
                searchModel.append(get(i))
            keywordQuery = ""
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

    ListModel {
        id: searchModel
    }

    property alias playerPanel: audioPanel
    AudioPlayerPanel {
        id: audioPanel

        page: searchPage

        onPrevious: {
            if(canGoPrevious) {
                currentItem--
                var item = searchModel.get(currentItem)
                if(item)
                    app.loadStation(item.id, Shoutcast.createInfo(item), tuneinBase)
            }
        }

        onNext: {
            if(canGoNext) {
                currentItem++
                var item = searchModel.get(currentItem)
                if(item)
                     app.loadStation(item.id, Shoutcast.createInfo(item), tuneinBase)
            }
        }
    }

    function reload() {
        showBusy = true
        if(nowPlayingQuery.length !== 0)
            nowPlayingModel.refresh()
        else
            app.loadKeywordSearch(keywordQuery, function(xml) {
                keywordModel.xml = xml
                keywordModel.reload()
                tuneinModel.xml = xml
                tuneinModel.reload()
            })
    }

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

            SearchField {
                id: searchField
                width: parent.width
                placeholderText: qsTr("Search text")
                Binding {
                    target: searchPage
                    property: "searchString"
                    value: searchField.text.toLowerCase().trim()
                }
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

        /*section.property : groupByField
        section.delegate : Component {
            id: sectionHeading
            Item {
                width: parent.width - 2*Theme.paddingMedium
                x: Theme.paddingMedium
                height: childrenRect.height

                Text {
                    text: section
                    font.bold: true
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.highlightColor
                }
            }
        }*/

        delegate: ListItem {
            id: delegate
            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium

            StationListItemView {
                id: stationListItemView
            }

            onClicked: {
                app.loadStation(model.id, Shoutcast.createInfo(model), tuneinBase)
                currentItem = index
            }
        }

        VerticalScrollDecorator {}

    }

}

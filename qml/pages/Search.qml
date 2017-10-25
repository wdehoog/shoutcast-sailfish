/**
 * Donnie. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


import QtQuick 2.0

import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nemomobile.configuration 1.0

import "../components"
import "../shoutcast.js" as Shoutcast

Page {
    id: searchPage

    property bool keepSearchFieldFocus: true
    property bool showBusy: false;
    property string searchString: ""
    property int startIndex: 0
    property int totalCount
    property var searchResults
    property var searchCapabilities: []
    property var scMap: []
    property string groupByField: groupby_search_results.value
    property string nowPlayingQuery: ""

    onSearchStringChanged: {
        typeDelay.restart()
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
            //var searchQuery = UPnP.createUPnPQuery(searchString, searchCapabilities, selectedSearchCapabilitiesMask, allowContainers);
            showBusy = true
            nowPlayingQuery = searchString
            //upnp.search(searchQuery, 0, maxCount);
            //console.log("search start="+startIndex);
        }
    }

    JSONListModel {
        id: nowPlayingModel
        source: nowPlayingQuery.length == 0 ? "" : (Shoutcast.NowPlayingSearchBase
                + "?" + Shoutcast.getPlayingPart(nowPlayingQuery)
                + "&" + Shoutcast.DevKeyPart
                + "&" + Shoutcast.QueryFormat)
        query: "$..station.*"
        keepQuery: "$..tunein"
    }

    Connections {
        target: nowPlayingModel
        onLoaded: {
            var i
            searchModel.clear()
            for(i=0;i<nowPlayingModel.model.count;i++)
                searchModel.append(nowPlayingModel.model.get(i))
            showBusy = false
        }
    }

    ListModel {
        id: searchModel
    }

    SilicaListView {
        id: listView
        model: searchModel
        anchors.fill: parent
        anchors {
            topMargin: 0
            bottomMargin: 0
        }

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
                id: groupBy
                width: parent.width
                label: qsTr("Search in")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Now Playing")
                        onClicked: {
                        }
                    }
                    MenuItem {
                        text: qsTr("Keyword")
                        onClicked: {
                        }
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

            Row {
                spacing: Theme.paddingMedium
                width: parent.width

                Column {
                    width: parent.width

                    Item {
                        width: parent.width
                        height: tt.height

                        Label {
                            id: tt
                            color: Theme.primaryColor
                            textFormat: Text.StyledText
                            truncationMode: TruncationMode.Fade
                            width: parent.width - dt.width
                            text: name
                        }
                        Label {
                            id: dt
                            anchors.right: parent.right
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: lc + " " + Shoutcast.getAudioType(mt) + " " + br
                        }
                    }

                    Label {
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        textFormat: Text.StyledText
                        truncationMode: TruncationMode.Fade
                        width: parent.width
                        text: ct ? ct : qsTr("no track info")
                    }
                }

            }

            onClicked: {
                app.loadStation(model.id, model.name, model.logo)
            }
        }

        VerticalScrollDecorator {}

    }

}

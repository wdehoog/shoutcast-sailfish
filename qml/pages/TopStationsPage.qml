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

    allowedOrientations: Orientation.All

    ListModel {
        id: stationsModel
    }

    XmlListModel {
        id: top500Model
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
            if(tuneinModel.count > 0) {
                tuneinBase = {}
                var b = tuneinModel.get(0)["base"]
                if(b)
                    tuneinBase["base"] = b
                b = tuneinModel.get(0)["base-m3u"]
                if(b)
                    tuneinBase["base-m3u"] = b
                b = tuneinModel.get(0)["base-xspf"]
                if(b)
                    tuneinBase["base-xspf"] = b
            } else
                tuneinBase = {}
        }
    }

    function reload() {
        showBusy = true
        app.loadTop500(function(xml) {
            top500Model.xml = xml
            tuneinModel.xml = xml
        })
    }

    Component.onCompleted: reload()

    property alias playerPanel: audioPanel
    AudioPlayerPanel {
        id: audioPanel
        //flick: top500Page.co
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
            x: Theme.paddingMedium

            Column {
                width: parent.width

                Item {
                    width: parent.width
                    height: nameLabel.height

                    Label {
                        id: nameLabel
                        color: Theme.primaryColor
                        textFormat: Text.StyledText
                        truncationMode: TruncationMode.Fade
                        width: parent.width - countLabel.width
                        text: name
                    }
                    Label {
                        id: countLabel
                        anchors.right: parent.right
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: lc + " " + Shoutcast.getAudioType(mt) + " " + br
                    }
                }

                Label {
                    color: currentItem === index ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    textFormat: Text.StyledText
                    truncationMode: TruncationMode.Fade
                    width: parent.width
                    text: (genre ? (genre + " - ") : "") + (ct ? ct : qsTr("no track info"))
                }
            }

            onClicked: {
                app.loadStation(model.id, Shoutcast.createInfo(model), tuneinBase)
            }
        }

    }

}


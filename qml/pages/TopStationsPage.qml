/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0

import "../shoutcast.js" as Shoutcast

Page {
    id: top500Page
    objectName: "TopStationsPage"

    property int currentItem: -1

    property bool showBusy: false
    property string tuneinBase: ""

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
            if(tuneinModel.count > 0)
                tuneinBase = tuneinModel.get(0)["base-m3u"]
            else
                tuneinBase = ""
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

    SilicaListView {
        id: genreView
        model: top500Model
        anchors.fill: parent
        anchors {
            topMargin: 0
            bottomMargin: 0
        }

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
                    //visible: metaText ? metaText.length > 0 : false
                    text: ct ? ct : qsTr("no track info")
                }
            }

            onClicked: {
                app.loadStation(model.id, model.name, model.logo, tuneinBase)
            }
        }

    }

}


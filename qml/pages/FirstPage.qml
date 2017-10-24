/*
  Copyright (C) 207 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../shoutcast.js" as Shoutcast

Page {
    id: page

    property bool showBusy: true

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    JSONListModel {
        id: genresModel
        source: Shoutcast.PrimaryGenreBase + "?" + Shoutcast.DevKeyPart + "&" + Shoutcast.QueryFormat
        query: "$..genre.*"
        Component.onCompleted: showBusy = false
    }


    SilicaListView {
        id: genreView
        model: genresModel.model
        anchors.fill: parent
        anchors {
            topMargin: 0
            bottomMargin: 0
        }

        /*PullDownMenu {
            MenuItem {
                text: qsTr("Reload")
                //enabled: browseModel.count < totalCount
                onClicked: loadGenres()
            }
        }*/

        header: Column {
            id: lvColumn

            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge

            PageHeader {
                id: pHeader
                title: qsTr("Genres")
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
                    //height: nameLabel.height

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
                        text: count

                    }
                }

            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("SubGenrePage.qml"),
                               {genreId: model.id, genreName: model.name})
            }
        }

    }

//    function loadGenres() {
//        var i
//        for(i=0;i<genresModel.count;i++)
//            console.log(genresModel.model.get(i))
//    }
}


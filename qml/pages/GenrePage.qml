/*
  Copyright (C) 207 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../shoutcast.js" as Shoutcast

Page {
    id: genrePage
    objectName: "GenrePage"

    property bool showBusy: true

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    JSONListModel {
        id: genresModel
        source: Shoutcast.PrimaryGenreBase + "?" + Shoutcast.DevKeyPart + "&" + Shoutcast.QueryFormat
        query: "$..genre.*"
    }

    Connections {
        target: genresModel
        onLoaded: showBusy = false
    }

    /* tried to use contextmenu but the lists can be too long
    property string genreId: ""
    property var currentGenreItem
    JSONListModel {
        id: subGenresModel
        source: Shoutcast.SecondaryGenreBase
                + "?" + Shoutcast.getParentGenrePart(genreId)
                + "&" + Shoutcast.DevKeyPart
                + "&" + Shoutcast.QueryFormat
        query: "$..genre.*"
    }*/

    SilicaListView {
        id: genreView
        model: genresModel.model
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
            property alias repr: repr
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

            /*Connections {
                target: subGenresModel
                onLoaded: {
                    showBusy = false
                    //menu.show(currentGenreItem)
                }
            }

            menu: ContextMenu {
                id: cmemu
                Repeater {
                    id: repr
                    model: subGenresModel.model
                    MenuItem {
                        text: model.name + " - " + model.count
                    }
                }
            }

            onPressed: {
                showBusy = true
                currentGenreItem = this
                genreId = model.id
            }*/

            onClicked: {
                var page = pageStack.nextPage()
                if(!page)
                    pageStack.pushAttached(Qt.resolvedUrl("SubGenrePage.qml"),
                                           {genreId: model.id, genreName: model.name})
                else {
                    page.genreId = model.id
                    page.genreName = model.name
                }

                pageStack.navigateForward(PageStackAction.Animated)
            }
        }

    }

//    function loadGenres() {
//        var i
//        for(i=0;i<genresModel.count;i++)
//            console.log(genresModel.model.get(i))
//    }
}


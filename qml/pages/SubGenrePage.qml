/*
  Copyright (C) 207 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../shoutcast.js" as Shoutcast

Page {
    id: subGenrePage
    objectName: "SubGenrePage"

    property string genreName: ""
    property string genreId: ""

    property bool showBusy: false

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    JSONListModel {
        id: genresModel
        source: Shoutcast.SecondaryGenreBase
                + "?" + Shoutcast.getParentGenrePart(genreId)
                + "&" + Shoutcast.DevKeyPart
                + "&" + Shoutcast.QueryFormat
        query: "$..genre.*"
    }

    onGenreIdChanged: {
        showBusy = true
    }

    function reload() {
        showBusy = true
        genresModel.refresh()
    }

    /*onStatusChanged: {
        if(status === PageStatus.Active)
            reload()
    }*/

    Connections {
        target: genresModel
        onLoaded: {
            showBusy = false
            /*if(genresModel.count == 0
               && app.scrapeWhenNoData.value) {
                // search for primary genre
                var i
                var primaryGenre = {}
                for(i=0;i<Shoutcast.primaryGenres.length;i++) {
                    if(Shoutcast.primaryGenres[i].genreid === genreId) {
                        primaryGenre = Shoutcast.primaryGenres[i]
                    }
                }
                // load subgenres
                for(i=0;i<primaryGenre.subgenres.length;i++) {
                    genresModel.model.append(
                        {name: primaryGenre.subgenres[i].name,
                         id: primaryGenre.subgenres[i].genreid,
                         count: ""})
                }
            }*/
        }
        onTimeout: {
            showBusy = false
            app.showErrorDialog(qsTr("SHOUTcast server did not respond"))
            console.log("SHOUTcast server did not respond")
        }
    }

    SilicaListView {
        id: genreView
        model: genresModel.model
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
                var page = pageStack.nextPage()
                if(!page)
                    pageStack.pushAttached(Qt.resolvedUrl("StationsPage.qml"),
                                           {genreId: model.id, genreName: model.name})
                else {
                   page.genreId = model.id
                   page. genreName = model.name
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


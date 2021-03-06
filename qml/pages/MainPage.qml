/**
 * Donnie. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


import QtQuick 2.2
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

import "../components"
import "../shoutcast.js" as Shoutcast

Page {
    property bool showBusy : false

    // 0 inactive, 1 load queue data, 2 load browse stack data
    property int resumeState: 0

    property alias playerPanel: audioPanel
    AudioPlayerPanel {
        id: audioPanel
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        anchors.bottomMargin: playerPanel.visibleSize
        //anchors.bottom: playerPanel.top
        clip: playerPanel.expanded

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                id: pHeader
                title: qsTr("Shoutcast Sailfish")
                BusyIndicator {
                    id: busyThingy
                    parent: pHeader.extraContent
                    anchors.left: parent.left
                    //running: showBusy
                }
            }

            Item {
                width: parent.width
                height: childrenRect.height

                Column {
                    id: appTitleColumn
                    spacing: Theme.paddingLarge

                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                        topMargin: Theme.paddingMedium
                    }

                    Rectangle {
                        width: parent.width
                        height: browseRow.height
                        opacity: 0
                    }

                    Row {
                        id: browseRow
                        anchors.horizontalCenter: parent.horizontalCenter
                        IconButton {
                            icon.source: "image://theme/icon-m-folder"
                            onClicked: gotoGenrePage();
                        }
                        Button {
                            text: qsTr("Genres")
                            onClicked: gotoGenrePage();
                        }
                    }
                    Row {
                        id: top500Row
                        anchors.horizontalCenter: parent.horizontalCenter
                        IconButton {
                            icon.source: "image://theme/icon-m-page-up"
                            onClicked: gotoTop500Page()
                        }
                        Button {
                            text: qsTr("Top 500")
                            onClicked: gotoTop500Page()
                        }
                    }

                    Row {
                        id: searchRow
                        anchors.horizontalCenter: parent.horizontalCenter
                        IconButton {
                            icon.source: "image://theme/icon-m-search"
                            onClicked: gotoSearchPage();
                        }
                        Button {
                            text: qsTr("Search")
                            onClicked: gotoSearchPage();
                        }
                    }

                }

            }

        }

        VerticalScrollDecorator { }
    }

    function gotoTop500Page() {
        if(!app.connectedToNetwork) {
            showErrorDialog(qsTr("There is no Network available."))
            return
        }
        var page = pageStack.nextPage()
        if(!page || page.objectName !== "TopStationsPage")
            pageStack.pushAttached(Qt.resolvedUrl("TopStationsPage.qml"))
        pageStack.navigateForward(PageStackAction.Animated)
    }

    function gotoGenrePage() {
        if(!app.connectedToNetwork) {
            showErrorDialog(qsTr("There is no Network available."))
            return
        }
        var page = pageStack.nextPage()
        if(!page || page.objectName !== "GenrePage")
            pageStack.pushAttached(Qt.resolvedUrl("GenrePage.qml"))
        pageStack.navigateForward(PageStackAction.Animated)
    }

    function gotoSearchPage() {
        if(!app.connectedToNetwork) {
            showErrorDialog(qsTr("There is no Network available."))
            return
        }
        var page = pageStack.nextPage()
        if(!page || page.objectName !== "Search")
            pageStack.pushAttached(Qt.resolvedUrl("Search.qml"))
        pageStack.navigateForward(PageStackAction.Animated)
    }


}

/**
 * Donnie. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingsPage

    allowedOrientations: Orientation.All


    onStatusChanged: {
        if (status === PageStatus.Activating) {
            msrField.text = app.maxNumberOfResults.value
            mprisServiceName.text = app.mprisPlayerServiceName.value
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Detect Mpris Players")
                onClicked: {
                    app.dbus.getServices("org.mpris.MediaPlayer2.", function(filteredServices) {
                        app.showMessageDialog("Mpris Players", filteredServices.join("\n"))
                    })
                }
            }
        }

        Column {
            id: column
            width: parent.width
            //height: childRect.height

            PageHeader { title: qsTr("Settings") }

            TextField {
                id: msrField
                label: qsTr("Maximum number of results per request")
                inputMethodHints: Qt.ImhDigitsOnly
                width: parent.width
                onTextChanged: {
                    app.maxNumberOfResults.value = text
                    app.maxNumberOfResults.sync()
                }
            }

            ComboBox {
                 label: qsTr("Player Type")
                 description: qsTr("Which type of player to use")

                 currentIndex: app.playerType.value

                 menu: ContextMenu {
                     MenuItem {
                         text: qsTr("Built In Player (Qt Audio)")
                         onClicked: app.playerType.value = 0
                     }
                     MenuItem {
                         text: qsTr("Mpris Player")
                         onClicked: app.playerType.value = 1
                     }
                 }
            }

            TextField {
                id: mprisServiceName
                label: qsTr("Mpris Service Name (skip 'org.mpris.MediaPlayer2')")
                inputMethodHints: Qt.ImhDigitsOnly
                width: parent.width
                onTextChanged: {
                    app.mprisPlayerServiceName.value = text
                    app.mprisPlayerServiceName.sync()
                }
            }

        }
    }

}


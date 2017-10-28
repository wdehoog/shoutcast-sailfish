/**
 * Donnie. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingsPage

    property alias mprisServiceName: mprisServiceName

    allowedOrientations: Orientation.All


    onStatusChanged: {
        if (status === PageStatus.Activating) {
            msrField.text = app.maxNumberOfResults.value
            var curValue = app.mprisPlayerServiceName.value
            if(curValue[0] === ".")
                curValue = curValue.substring(1)
            mprisServiceName.text = curValue
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        ListModel { id: items }

        PullDownMenu {
            MenuItem {
                text: qsTr("Detect Mpris Players")
                onClicked: {
                    app.dbus.getServices("org.mpris.MediaPlayer2.", function(filteredServices) {
                        items.clear()
                        for(var i=0;i<filteredServices.length;i++) {
                            if(filteredServices[i] !== app.mprisServiceName) // skip ourselves
                                items.append({id: i, name: filteredServices[i]})
                        }
                        var ms = pageStack.push(Qt.resolvedUrl("../dialogs/ItemPicker.qml"),
                                                {items: items, label: qsTr("Mpris Players")} );
                        ms.accepted.connect(function() {
                            if(ms.selectedIndex === -1)
                                return
                            mprisServiceName.text = ms.items.get(ms.selectedIndex).name
                        })
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
                    var newValue = text
                    if(newValue[0] !== ".")
                        newValue = "." + newValue
                    app.maxNumberOfResults.value = newValue
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


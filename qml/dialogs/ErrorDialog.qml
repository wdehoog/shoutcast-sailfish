import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property string titleText: "Error"
    property string errorMessageText : ""
    property bool   cancelAll: false
    property bool   showCancelAll: false

    id: errorDialog
    canAccept: true

    allowedOrientations: Orientation.All

    //onAccepted: {
    //}

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader { title: titleText }

            TextArea {
                id: logTextArea
                width: parent.width
                readOnly: true
                text: errorMessageText
            }

            /*TextSwitch {
                 id: cancelAllSwitch
                 visible: showCancelAll
                 text: "Cancel All"
                 description: "Cancels all loading"
                 onCheckedChanged: cancelAll = checked
            }*/
        }

        VerticalScrollDecorator{}
    }
}

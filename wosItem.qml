import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "Constants.js" as Constants

Item {
    id: itemContainer
    height: parent.height*0.15
    width: parent.width
    property var name: ""
    function setProps(set_name) {
        name = set_name
    }

    Button {
        id: button
        x: 0
        y: 0
        width: itemContainer.width
        height: itemContainer.height
        Material.background: Constants.foregroundDark
        hoverEnabled: false
        focusPolicy: Qt.StrongFocus
        enabled: true
        display: AbstractButton.IconOnly
        onClicked: {
            addSetsView.exercise_name = name
            root.toggleSetsView(true)
        }

        Text {
            id: txt
            x: 8
            y: 9
            width: 156
            height: 55
            color: Constants.text1
            text: name
            font.pixelSize: itemContainer.height*0.2
        }
    }


}

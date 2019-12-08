import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Item {
    id: itemContainer
    height: parent.height*0.15
    width: parent.width
    Button {
        id: button
        x: 0
        y: 0
        width: itemContainer.width
        height: itemContainer.height
        text: qsTr("Button")
        hoverEnabled: false
        focusPolicy: Qt.StrongFocus
        enabled: true
        display: AbstractButton.IconOnly

        Text {
            id: element
            x: 8
            y: 9
            width: 156
            height: 55
            color: "#b57979"
            text: qsTr("Excercise name")
            font.pixelSize: itemContainer.height*0.2
        }
    }


}

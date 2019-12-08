import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

ItemDelegate {
    id: itemRoot
    width: parent.width
    height: parent.height*0.07
    property var name: "none"
    function setName(new_name){
        name = new_name
    }
    text: itemRoot.name
    onClicked: itemRoot.setName("Clicked")

}

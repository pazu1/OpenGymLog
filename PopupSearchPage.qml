import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import com.pz.exercise 1.0
import com.pz.singleset 1.0
import com.pz.workout 1.0
import "Constants.js" as CT

Item {
    width: addWOSPopup.width
    height: addWOSPopup.height

    function refreshItems(){
        searchItemsColumn.populateWithItems()
    }

    TextField {
        id: searchField
        text: ""
        width: parent.width
        height: parent.height*0.07
        placeholderText: " type to search"
        onTextChanged:
            searchItemsColumn.searchParse(text)
    }

    ScrollView {
        id: popupScrollView
        width: parent.width
        y: searchField.height
        height: parent.height-tabBar.height-searchField.height
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Component {
            id: createdSearchItem

            ItemDelegate {
                id: searchItem
                width: searchItemsColumn.width
                height: searchItemsColumn.height*0.07
                property var name: "none"
                function setName(new_name){
                    name = new_name
                }
                text: name
                onNameChanged: {
                    if (name === "none")
                        destroy()
                }

                onClicked: {
                    addSetsView.exercise_name = searchItem.name
                    root.toggleSetsView(true)
                    addWOSPopup.close()
                }
            }
        }

        Column {
            id: searchItemsColumn
            width: popupScrollView.width
            height: popupScrollView.height


            function populateWithItems() {

                // Clear children items
                for(var c = searchItemsColumn.children.length; c > 0 ; c--) {
                    searchItemsColumn.children[c-1].destroy()
                }

                // Create new children items
                for(var i = 0; i<root.exercisesDB.length; i++){
                    var search_item = createdSearchItem.createObject(searchItemsColumn)
                    search_item.setName(root.exercisesDB[i].getName())
                }
                popupScrollView.clip = true
            }

            function searchParse(search_word)
            {
                for(var i = searchItemsColumn.children.length; i > 0 ; i--) {
                    searchItemsColumn.children[i-1].visible = true
                    if (!searchItemsColumn.children[i-1].name.toUpperCase().includes(search_word.toUpperCase()))
                        searchItemsColumn.children[i-1].visible = false
                }
            }
        }
    }

    ToolBar {
        id: tabBar
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        Material.background: CT.c_themes[cfg.theme].bg1
        ToolButton {
            id: cancelButton
            text: "Cancel"
            Material.foreground: CT.c_themes[cfg.theme].txt
            hoverEnabled: false
            width: parent.width / 2
            onClicked: addWOSPopup.close()
        }
        ToolSeparator {
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ToolButton {
            id: addExButton
            text: "New exercise"
            Material.foreground: CT.c_themes[cfg.theme].txt
            hoverEnabled: false
            anchors.right: parent.right
            anchors.rightMargin: 0
            width: parent.width / 2
            onClicked: addWOSPopup.toggleAddExPage(true)
        }
    }
}

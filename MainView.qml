import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import com.pz.exercise 1.0
import com.pz.singleset 1.0
import com.pz.workout 1.0
import "Constants.js" as Constants

Item {
    width: root.width; height:root.height
    Popup {
        id: addWOSPopup
        x: root.width*(0.15/2)
        y: root.height*(0.15/2)
        width: root.width*0.85
        height: root.height*0.85
        horizontalPadding: 1
        verticalPadding: 1
        clip: true
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        onOpened: {
            root.updateExercises()
            searchItemsColumn.populateWithItems()
        }

        TextField {
            id: searchField

            text: ""
            width: addWOSPopup.width
            height: addWOSPopup.height*0.07
            placeholderText: " type to search"

            onTextEdited:
                searchItemsColumn.searchParse(text)
        }

        TabBar {
            id: tabBar
            y: addWOSPopup.height-height
            position: TabBar.Footer
            width: addWOSPopup.width
            anchors.bottom: addWOSPopup.bottom
            TabButton {
                id: cancelButton
                text: "Cancel"
                hoverEnabled: false
                onClicked:
                    addWOSPopup.close()
            }
        }

        ScrollView {
            id: popupScrollView
            width: parent.width
            y: searchField.height
            height: parent.height-cancelButton.height-y
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
                        //console.log("destroying: " + c)
                        searchItemsColumn.children[c-1].destroy()
                    }

                    // Create new children items
                    console.log(dataStore.getExerciseAmount())
                    for(var i = 0; i<dataStore.getExerciseAmount(); i++){
                        var search_item = createdSearchItem.createObject(searchItemsColumn)
                        search_item.setName(root.exercises[i].getName())
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
    }

    Pane {
        height: root.height
        width: root.width
        Material.background: Constants.backgroundDark
    }

    ToolBar {
        id: toolBarMain
        x: 0
        y: 0
        z: 1
        width: root.width
        height: 66*scale_y
        opacity: 1
        Material.background: Constants.accent1

        Text {
            x: 0
            y: 0
            width: toolBarMain.width
            height: toolBarMain.height
            color: "#000000"
            text: selectedDate.toDateString()
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 22*scale_y
        }
    }

    ScrollView {
        id: scrollView
        x: 12
        width: root.width*0.95
        anchors.topMargin: root.height*0.095
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.bottomMargin: 0
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Column {
            id: columnWosItems
            width: scrollView.width
            height: scrollView.height
        }
    }

    Text {
        id: debug
        x: root.width*0.1
        y: root.height*0.9
        z: 10
        width: 300
        height: 82
        color: "#00e290"
        text: qsTr("Text")
        font.pixelSize: 12
    }

    RoundButton {
        id: addWOSButton
        x: 338
        y: 584
        width: 75*root.scale_factor
        height: 75*root.scale_factor
        text: "+"
        visible: true
        font.pointSize: 28
        font.bold: true
        Material.background: Constants.accent1
        Material.foreground: "#000000"
        onClicked: {
            addWOSPopup.open()
            var component = Qt.createComponent("wosItem.qml")
            component.createObject(columnWosItems)
        }
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40

    }
}



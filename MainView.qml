import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import com.pz.exercise 1.0
import com.pz.singleset 1.0
import com.pz.workout 1.0
import "Constants.js" as Constants

Item {
    width: root.width; height:root.height

    function clearWosComponents()
    {
        for (var d = columnWosItems.children.length; d > 0; d-- )
            columnWosItems.children[d-1].destroy()
    }

    // Create components for workout sets on selected day
    function loadWosItems()
    {
        // Clear components
        clearWosComponents()

        var names = []
        var workout = dataStore.getWorkout(selectedDate)
        if (workout !== null)
        {
            // Populate sets array & create components
            for (var i = 0; i<workout.getSetCount(); i++)
            {

                if (workout.getSetAt == null)
                    console.log("null set")
                var set_name = workout.getSetAt(i).getExercise().getName()
                if (!names.includes(set_name))
                {
                    names.push(set_name)
                    var component = Qt.createComponent("wosItem.qml")
                    var created_obj = component.createObject(columnWosItems)
                    created_obj.setProps(set_name, workout)
                }
            }
            // Create components
            /*
            for (var n = 0; n<names.length; n++)
            {
                var component = Qt.createComponent("wosItem.qml")
                var created_obj = component.createObject(columnWosItems)
                created_obj.setProps(names[n])
            }*/
        }
    }

    function openPopup()
    {
        addWOSPopup.open()
    }

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
                        searchItemsColumn.children[c-1].destroy()
                    }

                    // Create new children items
                    for(var i = 0; i<dataStore.getExerciseAmount(); i++){
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
    }

    Pane {
        height: root.height
        width: root.width
        Material.background: Constants.backgroundDark
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
}



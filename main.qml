import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import com.pz.exercise 1.0
import com.pz.singleset 1.0
import com.pz.workout 1.0
import "Constants.js" as Constants

ApplicationWindow {
    id: root
    width: 480
    height: 855
    color: "#000000"
    visible: true
    title: qsTr("QML&C++")
    Material.theme: Material.Dark
    Material.accent: Constants.accent1
    property date selectedDate: dataStore.selectedDate
    property var scale_factor: (width+height)/(480+855)
    property var scale_y: height/855
    property var scale_x: width/480
    property var exercises: []
    function updateExercises() {
        for (var i = 0; i<dataStore.getExerciseAmount(); i++){
            exercises.push(dataStore.getExerciseAt(i))
        }
    }

    function toggleSetsView(visible)
    {
        addSetsView.visible = visible
        mainView.visible = !visible
        if (visible)
        {
            console.log("Empty sets")
            addSetsView.loadSets()
        }
        else addSetsView.clearSets()
    }

    onClosing: {
        if (addSetsView.visible)
        {
            close.accepted = false
            toggleSetsView(false)
        }
    }

    Item {id: addSetsView; width: root.width; height:root.height
        visible: false

        property string exercise_name: "add new"
        property var sets: []

        function clearSets(){
            for (var d = oneExerciseWorkoutCO.children.length; d > 0; d-- )
            {
                oneExerciseWorkoutCO.children[d-1].destroy()
            }
            sets.length = 0;
        }

        function loadSets(){

            var workout = dataStore.getWorkout(selectedDate)
            if (workout !== null)
            {
                // Populate sets array
                for (var i = 0; i<workout.getSetCount(); i++)
                {
                    var set = workout.getSetAt(i)
                    if (set.getExercise().getName() == exercise_name)
                    {
                        sets.push(set)
                    }
                }
                createComponents()
            }
        }

        function createComponents(){
            var index = 0
            for (var setI = 0 ; setI < sets.length; setI++)
            {
                var current_set = sets[setI]
                for (var n = 0; n < current_set.getAmount(); n++)
                {
                    index++
                    var item = createdSetBar.createObject(oneExerciseWorkoutCO)
                    item.setProps(index,current_set)
                }
            }
        }

        Pane {
            id: backPane
            width: root.width
            height: root.height
            Material.background: Constants.backgroundDark
        }

        Component {
            id: createdSetBar
            SingleSetBar {
                width: oneExerciseWorkoutCO.width
                height: oneExerciseWorkoutCO.height*0.1
            }
        }

        ScrollView {
            id: selectedExerciseSetsSW
            x: 0
            y: pane.height+5*scale_y
            width: root.width
            height: root.height-pane.height-tabBarAS.height-10*scale_y
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            Column {
                id: oneExerciseWorkoutCO
                spacing: 5*scale_y
                x: 25*scale_x
                width: selectedExerciseSetsSW.width*0.9
                height: selectedExerciseSetsSW.height
            }

        }

        Pane {
            id: pane
            Material.background: Constants.foregroundDark
            width: root.width
            height: repsField.y+repsField.height
        }

        TabBar {
            id: tabBarAS
            y: addSetsView.height-height
            position: TabBar.Footer
            width: addSetsView.width
            anchors.bottom: addSetsView.bottom
            anchors.bottomMargin: 0
            Material.background: Constants.foregroundDark
            TabButton {
                text: "log"
                hoverEnabled: false
            }
            TabButton {
                text: "graph"
                hoverEnabled: false
            }

        }

        ToolBar {
            id: toolBarAS
            x: 0
            y: 0
            width: root.width
            height: 66*scale_y
            Material.background: Constants.accent1
            ToolButton {
                y: parent.height*0.5 - height*0.5
                icon.source: "qrc:/icons/arrow_back-24px.svg"
                icon.color: "#000000"
                icon.height: 34*scale_factor
                icon.width: 34*scale_factor
                display: AbstractButton.IconOnly
                onClicked:{
                    toggleSetsView(false)
                }

            }

            Text {
                id: element
                x: 0
                y: 0
                width: toolBarAS.width
                height: toolBarAS.height
                color: "#000000"
                text: addSetsView.exercise_name
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 22*scale_y
            }
        }

        Text {
            id: wText
            x: weightField.x-width*0.7
            y: weightField.y+weightField.height*0.25
            width: 120*scale_x
            height: 66
            color: Constants.text1
            text: qsTr("weight:")
            font.pixelSize: 22*scale_y
        }

        Text {
            id: rText
            x: repsField.x-width*0.7
            y: repsField.y+repsField.height*0.25
            width: 120*scale_x
            height: 40*scale_y
            color: Constants.text1
            text: qsTr("reps:")
            font.pixelSize: 22*scale_y
        }

        TextField {
            id: weightField
            x: 200*scale_x
            y: (repsField.y-repsField.height)
            width: 80
            height: 60*scale_y
            text: qsTr("")
            font.pixelSize: 22*scale_y
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }

        TextField {
            id: repsField
            x: 200*scale_x
            y: 160*scale_y
            width: 80
            height: 60*scale_y
            text: qsTr("")
            font.pixelSize: 22*scale_y
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }

        Button {
            id: setAddButton
            x: 346*scale_x
            y: repsField.y-height*0.3
            width: 107*scale_x
            height: 55*scale_y
            text: qsTr("Add set")
            onClicked:{
                var weight = parseFloat(weightField.text)
                var reps = parseInt(repsField.text)
                dataStore.addSingleSet(selectedDate,addSetsView.exercise_name, weight, reps)
                addSetsView.clearSets()
                addSetsView.loadSets()
            }
        }
    }

    Item {id: mainView; width: root.width; height:root.height
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
                            // TODO:
                            // create C++ object for this exercise on this date
                            // upon opening addSetsView, retrieve created object from C++
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
}

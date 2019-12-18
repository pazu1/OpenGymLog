import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import com.pz.exercise 1.0
import com.pz.singleset 1.0
import com.pz.workout 1.0
import "Constants.js" as CT

Item {
    width: root.width; height:root.height
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
        Material.background: CT.backgroundDark
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
        Material.background: CT.foregroundDark
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
        Material.background: CT.foregroundDark
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
        Material.background: CT.accent1
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
        color: CT.text1
        text: qsTr("weight:")
        font.pixelSize: 22*scale_y
    }

    Text {
        id: rText
        x: repsField.x-width*0.7
        y: repsField.y+repsField.height*0.25
        width: 120*scale_x
        height: 40*scale_y
        color: CT.text1
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

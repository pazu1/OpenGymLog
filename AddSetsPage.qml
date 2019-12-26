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
    Component {
        id: createdSetBar
        SingleSetBar {
            width: oneExerciseWorkoutCO.width
        }
    }

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
    Text {
        id: wText
        x: weightField.x-width*0.7
        y: weightField.y+weightField.height*0.25
        width: 120*scale_x
        height: 66
        color: CT.text1
        text: qsTr("weight:")
        font.pixelSize: font_b*scale
    }

    Text {
        id: rText
        x: repsField.x-width*0.7
        y: repsField.y+repsField.height*0.25
        width: 120*scale_x
        height: 40*scale_y
        color: CT.text1
        text: qsTr("reps:")
        font.pixelSize: font_b*scale
    }

    TextField {
        id: weightField
        x: 200*scale_x
        y: (repsField.y-repsField.height)
        width: 80
        height: 60*scale_y
        text: qsTr("")
        font.pixelSize: font_b*scale
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }

    TextField {
        id: repsField
        x: 200*scale_x
        y: 160*scale_y
        width: 80
        height: 60*scale_y
        text: qsTr("")
        font.pixelSize: font_b*scale
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
            if (dataStore.addSingleSet(selectedDate,addSetsView.exercise_name, weight, reps))
                loadAddSetsPage()
        }
    }
}

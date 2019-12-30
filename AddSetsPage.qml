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
        anchors.top: pane.bottom
        anchors.topMargin: 5*root_scale
        width: root.width
        height: root.height-pane.height-tabBarAS.height-toolBarAS.height-10*root_scale
        anchors.bottomMargin: 0
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Column {
            id: oneExerciseWorkoutCO
            spacing: 5*root_scale
            x: 25*root_scale
            width: selectedExerciseSetsSW.width*0.9
            height: selectedExerciseSetsSW.height
        }
    }

    Pane {
        id: pane
        Material.background: CT.foregroundDark
        anchors.top: parent.top
        anchors.topMargin: toolBarAS.height
        width: root.width
        height: root.height*0.2
    }
    Column
    {
        anchors.verticalCenter: pane.verticalCenter
        anchors.right: pane.right
        anchors.rightMargin: pane.width*0.35
        Row {
            id: firstRow
            spacing: 20
            Text {
                id: wText
                color: CT.text1
                text: qsTr("weight:")
                font.pixelSize: font_b*root_scale
                anchors.verticalCenter: parent.verticalCenter
            }
            TextField {
                id: weightField
                width: 80*root_scale
                text: qsTr("")
                font.pixelSize: font_b*root_scale
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Row {
            spacing: 20
            Text {
                id: rText
                color: CT.text1
                text: qsTr("reps:")
                font.pixelSize: font_b*root_scale
                anchors.verticalCenter: parent.verticalCenter
            }
            TextField {
                id: repsField
                width: 80*root_scale
                text: qsTr("")
                font.pixelSize: font_b*root_scale
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Button {
        id: setAddButton
        anchors.right: pane.right
        anchors.rightMargin: 17*root_scale
        anchors.bottom: pane.bottom
        anchors.bottomMargin: 10*root_scale
        width: 110*root_scale
        height: 55*root_scale
        text: qsTr("Add set")
        font.pixelSize: font_s*root_scale
        onClicked:{
            var weight = parseFloat(weightField.text)
            var reps = parseInt(repsField.text)
            if (dataStore.addSingleSet(selectedDate,addSetsView.exercise_name, weight, reps))
                updateSetElements()
            else
                rootAlert.showAlert(toolBarAS.y + toolBarAS.height, true, "Couldn't add set. Please enter valid reps and weight.")
        }
    }
}

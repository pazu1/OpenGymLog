import QtQuick 2.0
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import com.pz.exercise 1.0
import com.pz.singleset 1.0
import com.pz.workout 1.0
import "Constants.js" as CT

Item {
    function getText()
    {
        return "index: "+index
    }
    anchors.fill: parent

    Text {
        id: noWorkoutTxt
        anchors.centerIn: parent
        visible: false
        color: CT.text1
        text: "No workouts on this day."
    }

    function clearWosComponents()
    {
        for (var d = columnWosItems.children.length; d > 0; d-- )
            columnWosItems.children[d-1].destroy()
    }

    // Clear and create new components for workout sets on selected day
    function loadWosItems()
    {
        clearWosComponents()
        var names = []
        var workout = dataStore.getWorkout(selectedDate)
        if (workout !== null)
        {
            // Populate sets array & create components
            noWorkoutTxt.visible = (workout.getSetCount(true) == 0)
            for (var i = 0; i<workout.getSetCount(); i++)
            {
                var set_name = workout.getSetAt(i).getExercise().getName()
                if (!names.includes(set_name))
                {
                    names.push(set_name)
                    var component = Qt.createComponent("wosItem.qml")
                    var created_obj = component.createObject(columnWosItems)
                    created_obj.setProps(set_name, workout)
                }
            }
        }
        else
            noWorkoutTxt.visible = true
    }

    function getAmountOfSets()
    {
        if (columnWosItems.children.length == 0)
            noWorkoutTxt.visible = true
        else
            noWorkoutTxt.visible = false
        return columnWosItems.children.length
    }

    ScrollView {
        id: scrollView
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.width*0.9
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: mainBar.height + navigationBar.height+12*scale
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Column {
            id: columnWosItems
            width: scrollView.width
            height: scrollView.height
        }
    }
}


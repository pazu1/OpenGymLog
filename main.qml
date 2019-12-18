import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import com.pz.exercise 1.0
import com.pz.singleset 1.0
import com.pz.workout 1.0
import "Constants.js" as CT

ApplicationWindow {
    id: root
    width: 480
    height: 855
    color: "#000000"
    visible: true
    title: qsTr("QML&C++")
    Material.theme: Material.Dark
    Material.accent: CT.accent1
    property date selectedDate: dataStore.selectedDate
    property var scale_factor: (width+height)/(480+855)
    property var scale_y: height/855
    property var scale_x: width/480
    property var exercisesDB: []

    function updateExercises() {
        for (var i = 0; i<dataStore.getExerciseAmount(); i++){
            exercisesDB.push(dataStore.getExerciseAt(i))
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
        else
        {
            addSetsView.clearSets()
            mainView.loadWosItems()
        }
    }

    Component.onCompleted: {
        mainView.loadWosItems()
    }

    onClosing: {
        if (addSetsView.visible)
        {
            close.accepted = false
            toggleSetsView(false)
        }
    }

    SetsView{id:addSetsView}
    MainView{id: mainView}
}

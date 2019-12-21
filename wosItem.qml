import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "Constants.js" as CT

Item {
    id: itemContainer
    height: parent.height*0.1+column.height
    width: parent.width
    property var name: ""
    property var workout
    property var content_height: 0
    function setProps(set_name, set_workout) {
        name = set_name
        workout = set_workout

        for (var i = 0; i < workout.getSetCount(); i++)
        {
            if (workout.getSetAt(i).getExercise().getName() == name)
            {
                for (var n = 0; n < workout.getSetAt(i).getAmount(); n++)
                {
                    var item = createdSubSet.createObject(column)
                    item.setText(workout.getSetAt(i).getReps()+" reps    "+workout.getSetAt(i).getWeight()+" kg")
                }
            }
        }

    }

    Component {
        id: createdSubSet
        Pane {
            width: parent.width*0.92
            height: 30*scale
            anchors.horizontalCenter: parent.horizontalCenter
            Material.background: CT.foregroundDark

            function setText(new_text) {
                txt.text = new_text
            }

            Text {
                y:-5*scale
                id: txt
                text: "0x0"
                color: CT.text1
                font.pixelSize: scale*16
            }
        }
    }

    Button {
        id: button
        x: 0
        y: 0
        width: parent.width
        height: 55*scale
        Material.background: CT.foregroundDark
        hoverEnabled: false
        focusPolicy: Qt.StrongFocus
        enabled: true
        display: AbstractButton.IconOnly
        onClicked: {
            addSetsView.exercise_name = name
            root.toggleSetsView(true)
        }

        Text {
            id: txt
            x: 8*scale
            y: 9*scale
            color: CT.text1
            text: name
            font.pixelSize: scale*22
        }
    }
    Column {
        id: column
        spacing: 2*scale
        y: button.height
        width: parent.width
    }
}

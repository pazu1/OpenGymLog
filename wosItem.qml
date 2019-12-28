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
                    var form_w = (Math.round(workout.getSetAt(i).getWeight()*100) / 100).toFixed(2);
                    item.setText(workout.getSetAt(i).getReps()+" reps               "+form_w+" "+cfg.unit)
                }
            }
        }
        if (column.children.length == 0) // TODO: replace this with C++ code in deleteSet function
            destroy()
    }

    Component {
        id: createdSubSet
        Item {
            width: parent.width*0.92
            height: 30*scale
            anchors.horizontalCenter: parent.horizontalCenter
            Material.background: CT.foregroundDark

            function setText(new_text) {
                txt.text = new_text
            }

            Text {
                y:5*scale
                anchors.left: parent.left
                anchors.leftMargin: parent.width*0.03
                id: txt
                text: "0x0"
                color: CT.text1
                font.pixelSize: font_m*scale
            }
        }
    }

    Button {
        id: bottomButton
        height: column.height+button.height+2*scale
        width: parent.width*0.92
        anchors.horizontalCenter: parent.horizontalCenter
        hoverEnabled: false
        Material.background: CT.foregroundDark
        onClicked: {
            addSetsView.exercise_name = name
            root.toggleSetsView(true)
        }
    }

    Button {
        id: button
        x: 0
        y: 0
        z: 1
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
            font.pixelSize: font_b*scale
        }
    }
    Column {
        id: column
        y: button.height-5*scale
        width: parent.width
    }
}

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import com.pz.singleset 1.0
import "Constants.js" as CT

Item {
    id: singleSetBarRoot
    width: 200
    height: 40*scale
    property bool expanded: false
    property var obj_set

    states: [
        State {
            name: "normal"
            when: !expanded
            PropertyChanges {target: singleSetBarRoot; height: 40*scale}
        },
        State {
            name: "expanded"
            when: expanded
            PropertyChanges {target: singleSetBarRoot; height: 100*scale}
        }

    ]
    transitions: Transition {
                 PropertyAnimation { property: "height"; duration: 60; easing.type: Easing.InOutQuad }
    }

    function setProps(index, containedSet) {
        obj_set = containedSet
        t1.text = index+"."
        t2.text = obj_set.getReps()+" reps"
        t3.text = obj_set.getWeight()+" kg"
    }

    Pane {
        id: pane
        x: 0
        y: 0
        Material.background: CT.foregroundDark
        width: singleSetBarRoot.width
        height: singleSetBarRoot.height
    }

    Button {
        text: "delete"
        visible: expanded
        anchors.top: parent.top
        anchors.topMargin: 50*scale
        anchors.right: parent.right
        anchors.rightMargin: 30*scale
        onClicked: {
            dataStore.deleteObject(obj_set)
            loadAddSetsPage()
            //singleSetBarRoot.destroy()
        }
    }

    ItemDelegate {
        id: baseItem
        width: singleSetBarRoot.width
        height: 40*scale
        anchors.top: parent.top
        anchors.topMargin: 0
        font.pixelSize: 22*scale_x

        onClicked:
        {
            expanded = !expanded
        }

        Text {
            id: t1
            x: singleSetBarRoot.width*0.02
            anchors.verticalCenter: parent.verticalCenter
            color: CT.text1
            text: qsTr("Text")
            font.pixelSize: 22*scale_x
        }

        ToolSeparator {
            id: toolSeparator
            anchors.left: parent.left
            anchors.leftMargin: parent.width*0.15
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: t2
            x: singleSetBarRoot.width*0.3
            anchors.verticalCenter: parent.verticalCenter
            color: CT.text1
            text: qsTr("Text")
            font.pixelSize: 22*scale_x
        }

        ToolSeparator {
            id: toolSeparator1
            anchors.left: parent.left
            anchors.leftMargin: t3.x - (t3.x-t2.x)*0.5 + t2.height*0.5
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: t3
            x: singleSetBarRoot.width*0.7
            anchors.verticalCenter: parent.verticalCenter
            color: CT.text1
            text: qsTr("Text")
            font.pixelSize: 22*scale_x
        }
    }
}

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
    height: 50*root_scale
    property bool expanded: false
    property var obj_set

    states: [
        State {
            name: "normal"
            when: !expanded
            PropertyChanges {target: singleSetBarRoot; height: 50*root_scale}
        },
        State {
            name: "expanded"
            when: expanded
            PropertyChanges {target: singleSetBarRoot; height: 120*root_scale}
        }

    ]
    transitions: Transition {
                 PropertyAnimation { property: "height"; duration: 60; easing.type: Easing.InOutQuad }
    }

    function setProps(index, containedSet) {
        obj_set = containedSet
        var form_w = (Math.round(obj_set.getWeight()*100) / 100).toFixed(2);
        t1.text = index+"."
        t2.text = obj_set.getReps()+" reps"
        t3.text = form_w+" "+cfg.unit
    }

    Pane {
        id: pane
        x: 0
        y: 0
        Material.background: CT.c_themes[cfg.theme].bg2
        width: singleSetBarRoot.width
        height: singleSetBarRoot.height
    }



    Button {
        text: "delete"
        visible: expanded
        anchors.top: parent.top
        anchors.topMargin: 50*root_scale
        anchors.right: parent.right
        anchors.rightMargin: 30*root_scale
        onClicked: {
            dataStore.deleteSet(obj_set)
            updateSetElements()
        }
    }

    ItemDelegate {
        id: baseItem
        width: singleSetBarRoot.width
        height: 50*root_scale
        anchors.top: parent.top
        anchors.topMargin: 0
        font.pixelSize: font_b*root_scale

        onClicked:
        {
            expanded = !expanded
        }

        Text {
            id: t1
            anchors.verticalCenter: baseItem.verticalCenter
            anchors.left: baseItem.left
            anchors.leftMargin: 15*root_scale
            color: CT.c_themes[cfg.theme].txt
            text: qsTr("Text")
            font.pixelSize: font_b*root_scale
        }

        ToolSeparator {
            id: toolSeparator
            anchors.verticalCenter: baseItem.verticalCenter
            anchors.left: t1.right
            anchors.leftMargin: 0
            height: 50*root_scale
        }

        Text {
            id: t2
            anchors.verticalCenter: baseItem.verticalCenter
            anchors.left: t1.right
            anchors.leftMargin: 70*root_scale
            color: CT.c_themes[cfg.theme].txt
            text: qsTr("Text")
            font.pixelSize: font_b*root_scale
        }

        Item {
            id: middlePos
            anchors.verticalCenter: baseItem.verticalCenter
            anchors.left: t2.right
            anchors.right: t3.left
            visible: false
            height: 50*root_scale
        }
        ToolSeparator {
            id: toolSeparator2
            anchors.verticalCenter: baseItem.verticalCenter
            anchors.horizontalCenter: middlePos.horizontalCenter
            height: 50*root_scale
        }
        Text {
            id: t3
            anchors.verticalCenter: baseItem.verticalCenter
            anchors.right: baseItem.right
            anchors.rightMargin: 15*root_scale
            color: CT.c_themes[cfg.theme].txt
            text: qsTr("Text")
            font.pixelSize: font_b*root_scale
        }

    }
}

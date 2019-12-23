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
    width: addWOSPopup.width
    height: addWOSPopup.height

    onVisibleChanged: {
        if (visible)
            ctgCombo.model = dataStore.getCategories()
    }

    Text {
        id: nameLbl
        text: "Exercise name:"
        anchors.left: parent.left
        anchors.leftMargin: 15*scale
        anchors.top: parent.top
        anchors.topMargin: 40*scale
        font.pixelSize: 22*scale_x
        color: CT.text1
    }

    TextField {
        id: nameFld
        anchors.right: parent.right
        anchors.rightMargin: 8*scale
        anchors.top: parent.top
        anchors.topMargin: 30*scale
        font.pixelSize: 22*scale_x
        width: parent.width*0.5
    }

    Text {
        id: ctgLbl
        text: "Category:"
        anchors.left: parent.left
        anchors.leftMargin: 15*scale
        anchors.top: parent.top
        anchors.topMargin: 120*scale
        font.pixelSize: 22*scale_x
        color: CT.text1
    }

    ComboBox {
        id: ctgCombo
        editable: true
        anchors.right: parent.right
        anchors.rightMargin: 8*scale
        anchors.top: parent.top
        anchors.topMargin: 110*scale
        width: parent.width*0.5
        font.pixelSize: 22*scale_x
        model: []
    }

    ToolBar {
        id: tabBar
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        Material.background: CT.foregroundLight


        ToolButton {
            id: cancelButton
            text: "Cancel"
            hoverEnabled: false
            width: parent.width / 2
            onClicked:
                addWOSPopup.close()
        }
        ToolSeparator {
            anchors.horizontalCenter: parent.horizontalCenter
        }
        ToolButton {
            id: addExButton
            text: "create new"
            hoverEnabled: false
            anchors.right: parent.right
            anchors.rightMargin: 0
            width: parent.width / 2
            onClicked:
            {
                dataStore.addExercise(nameFld.text,ctgCombo.currentText)
                root.updateExercises()
                addSetsView.exercise_name = nameFld.text
                root.toggleSetsView(true)
                addWOSPopup.close()
            }
        }
    }
}

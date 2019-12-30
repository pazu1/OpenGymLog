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
        anchors.leftMargin: 15*root_scale
        anchors.top: parent.top
        anchors.topMargin: 40*root_scale
        font.pixelSize: font_b*root_scale
        color: CT.text1
    }

    TextField {
        id: nameFld
        anchors.right: parent.right
        anchors.rightMargin: 8*root_scale
        anchors.top: parent.top
        anchors.topMargin: 30*root_scale
        font.pixelSize: font_b*root_scale
        width: parent.width*0.5
    }

    Text {
        id: ctgLbl
        text: "Category:"
        anchors.left: parent.left
        anchors.leftMargin: 15*root_scale
        anchors.top: parent.top
        anchors.topMargin: 120*root_scale
        font.pixelSize: font_b*root_scale
        color: CT.text1
    }

    ComboBox {
        id: ctgCombo
        anchors.right: parent.right
        anchors.rightMargin: 8*root_scale
        anchors.top: parent.top
        anchors.topMargin: 110*root_scale
        width: parent.width*0.5
        font.pixelSize: font_b*root_scale
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
            text: "back"
            hoverEnabled: false
            width: parent.width / 2
            onClicked:
                addWOSPopup.toggleAddExPage(false)
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
                if (dataStore.addExercise(nameFld.text,ctgCombo.currentText))
                {
                    root.updateExercises()
                    addSetsView.exercise_name = nameFld.text
                    root.toggleSetsView(true)
                    addWOSPopup.close()
                    rootAlert.showAlert(mainBar.y + mainBar.height,false,"Created exercise: " + nameFld.text)
                }
                else
                    popupAlert.showAlert(0,true,"Error: Invalid exercise name")
            }
        }
    }
}

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
    id: itemRoot
    width: addWOSPopup.width
    height: addWOSPopup.height

    onVisibleChanged: {
        if (visible)
            ctgCombo.model = dataStore.getCategories()
    }

    Dialog {
        id: categoryCreationDialog
        title: "New category"
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        modal: true
        width: parent.width
        height: parent.height*0.3
        Overlay.modal: Rectangle {
                color: "#85000000"
            }
        TextField {
            id: addCatgTextField
            anchors.centerIn: parent
            width: parent.width
        }
        onAccepted: {
            var edited = ctgCombo.model
            edited.push(addCatgTextField.text)
            ctgCombo.model = edited
            ctgCombo.currentIndex = edited.length-1
        }
    }

    Column {
        topPadding: 20*root_scale
        spacing: 10*root_scale
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            id: nameLbl
            text: "Exercise name:"
            font.pixelSize: font_b*root_scale
            color: CT.text1
        }

        TextField {
            id: nameFld
            font.pixelSize: font_b*root_scale
            width: itemRoot.width*0.8
        }

        Text {
            id: ctgLbl
            text: "Category:"
            font.pixelSize: font_b*root_scale
            color: CT.text1
        }

        ComboBox {
            id: ctgCombo
            width: itemRoot.width*0.8
            font.pixelSize: font_b*root_scale
            model: []
        }
        Button {
            text: "Create category"
            width: itemRoot.width*0.75
            anchors.horizontalCenter: parent.horizontalCenter
            height: 65*root_scale
            font.pixelSize: font_m*root_scale
            onClicked: categoryCreationDialog.open()
        }
    }

    ToolBar {
        id: tabBar
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        Material.background: CT.backgroundDark

        ToolButton {
            id: cancelButton
            text: "back"
            Material.foreground: CT.text1
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
            Material.foreground: CT.text1
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
                    popupAlert.showAlert(0,true,"Error: Invalid exercise or category name")
            }
        }
    }
}

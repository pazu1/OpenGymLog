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
        title: "Create new category"
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
            text: "Enter exercise name:"
            font.pixelSize: font_b*root_scale
            color: CT.c_themes[cfg.theme].txt
        }

        TextField {
            id: nameFld
            font.pixelSize: font_b*root_scale
            width: itemRoot.width*0.8
        }

        Text {
            id: ctgLbl
            text: "Select category:"
            font.pixelSize: font_b*root_scale
            color: CT.c_themes[cfg.theme].txt
        }

        ComboBox {
            id: ctgCombo
            width: itemRoot.width*0.8
            font.pixelSize: font_b*root_scale
            model: []
        }
        Text {
            text: "or"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: font_b*root_scale
            color: CT.c_themes[cfg.theme].txt
        }
        Button {
            text: "Create new category"
            width: itemRoot.width*0.6
            anchors.horizontalCenter: parent.horizontalCenter
            height: 65*root_scale
            font.pixelSize: font_s*root_scale
            onClicked: categoryCreationDialog.open()
        }
    }

    ToolBar {
        id: tabBar
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        Material.background: CT.c_themes[cfg.theme].bg1

        ToolButton {
            id: cancelButton
            text: "back"
            Material.foreground: CT.c_themes[cfg.theme].txt
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
            Material.foreground: CT.c_themes[cfg.theme].txt
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

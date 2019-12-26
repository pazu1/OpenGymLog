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
    width: root.width; height:root.height

    function clearWosComponents()
    {
        for (var d = columnWosItems.children.length; d > 0; d-- )
            columnWosItems.children[d-1].destroy()
    }

    // Create components for workout sets on selected day
    function loadWosItems()
    {
        // Clear components
        clearWosComponents()

        var names = []
        var workout = dataStore.getWorkout(selectedDate)
        if (workout !== null)
        {
            // Populate sets array & create components
            for (var i = 0; i<workout.getSetCount(); i++)
            {

                if (workout.getSetAt == null)
                    console.log("null set")
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
    }

    function openPopup()
    {
        addWOSPopup.open()
    }

    Popup {
        id: addWOSPopup
        x: root.width*(0.15/2)
        y: root.height*(0.15/2)
        width: root.width*0.85
        height: root.height*0.85
        Material.background: CT.foregroundDark
        horizontalPadding: 0
        verticalPadding: 0
        clip: true
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        onOpened: {
            root.updateExercises()
            srchPage.refreshItems()
        }
        onClosed: {
            toggleAddExPage(false)
        }

        function toggleAddExPage(enable)
        {
            srchPage.visible = !enable
            addxPage.visible = enable
        }

        PopupSearchPage {id: srchPage}
        PopupAddExPage {id: addxPage; visible: false}


    }

    Pane {
        height: root.height
        width: root.width
        Material.background: CT.backgroundDark
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

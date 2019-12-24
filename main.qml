import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
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
    title: qsTr("OpenGymLog")
    Material.theme: Material.Dark
    Material.accent: CT.accent1
    property date selectedDate: dataStore.selectedDate
    property var scale_y: height/855
    property var scale_x: width/480
    property var exercisesDB: []

    function updateExercises() {
        exercisesDB.length = 0
        for (var i = 0; i<dataStore.getExerciseAmount(); i++){
            exercisesDB.push(dataStore.getExerciseAt(i))
        }
    }

    function toggleSetsView(visible)
    {
        addSetsView.visible = visible
        mainViewContainer.visible = !visible
        if (visible)
        {
            addSetsView.loadAddSetsPage()
        }
        else
        {
            swipeV.itemAt(1).loadWosItems()
        }
    }

    Component.onCompleted: {
        mainView.loadWosItems()
        swipeV.insertItem(0,l_mainView)
    }

    onClosing: {
        if (addSetsView.visible)
        {
            close.accepted = false
            toggleSetsView(false)
        }
    }

    SetsView{id:addSetsView}

    MainView{id: l_mainView}

    // Scroll related elements for main view
    Item {
        id: mainViewContainer
        anchors.fill: parent
        SwipeView {
            id: swipeV
            anchors.fill: parent
            interactive: false
            onCurrentIndexChanged: // TODO: fix; swiping to the left causes issues
            {
                if (currentIndex == 0)
                {
                    dataStore.scrollDate(-1)
                    moveItem(2,0)
                }
                else if (currentIndex == 2)
                {
                    dataStore.scrollDate(1)
                    moveItem(0,2)
                }
                itemAt(currentIndex).loadWosItems()
            }

            MainView{id: mainView}
            MainView{id: r_mainView}
        }

        ToolBar {
            id: toolBarMain
            x: 0
            y: 0
            z: 1
            width: root.width
            height: 66*scale_y
            opacity: 1
            Material.background: CT.accent1

            Text {
                x: 0
                y: 0
                width: toolBarMain.width
                height: toolBarMain.height
                color: "#000000"
                text: selectedDate.toDateString()
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 22*scale_y
            }

            ToolButton {
                id: navBack
                y: parent.height*0.5 - height*0.5
                icon.source: "qrc:/icons/arrow_back_ios-24px.svg"
                icon.color: "#000000"
                icon.height: 34*scale
                icon.width: 34*scale
                display: AbstractButton.IconOnly
                onClicked: swipeV.decrementCurrentIndex()
            }
            ToolButton {
                id: navForw
                y: parent.height*0.5 - height*0.5
                anchors.right: parent.right
                anchors.rightMargin: 0
                icon.source: "qrc:/icons/arrow_forward_ios-24px.svg"
                icon.color: "#000000"
                icon.height: 34*scale
                icon.width: 34*scale
                display: AbstractButton.IconOnly
                onClicked: swipeV.incrementCurrentIndex()
            }
        }

        RoundButton {
            id: addWOSButton
            x: 338
            y: 584
            width: 75*scale
            height: 75*scale
            text: "+"
            visible: true
            font.pointSize: 28
            font.bold: true
            Material.background: CT.accent1
            Material.foreground: "#000000"
            onClicked: {
                swipeV.itemAt(1).openPopup()
            }
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40

        }
    }
}

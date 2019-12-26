import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import Qt.labs.settings 1.0
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
    property int font_s: 14
    property int font_m: 16
    property int font_b: 22

    Settings {
        id: cfg
        property string unit: "kg"
        property int theme: 0
    }

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
            addSetsView.updateSetElements()
        else
            swipeV.itemAt(1).loadWosItems()
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

    // Scroll related elements for main view, TODO: move to own file
    MainView{id: l_mainView}
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
            id: mainBar
            anchors.top: parent.top
            z: 1
            width: root.width
            height: 66*scale
            opacity: 1
            Material.background: CT.accent1

            ToolButton {
                id: dMenuButton
                anchors.left: parent.left
                anchors.leftMargin: 10*scale_x
                icon.source: "qrc:/icons/menu-24px.svg"
                icon.height: 34*scale
                icon.width: 34*scale
                icon.color: "#000000"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: dMenu.open()
            }
        }

        ToolBar {
            id: navigationBar
            x: 0
            y: mainBar.height
            z: 1
            width: root.width
            height: 45*scale
            opacity: 1
            Material.background: CT.foregroundDark

            Text {
                x: 0
                y: 0
                width: navigationBar.width
                height: navigationBar.height
                color: CT.text1
                text: selectedDate.toDateString()
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: font_b*scale
            }

            ToolButton {
                id: navBack
                y: parent.height*0.5 - height*0.5
                icon.source: "qrc:/icons/arrow_back_ios-24px.svg"
                icon.color: CT.text1
                icon.height: 25*scale
                icon.width: 25*scale
                display: AbstractButton.IconOnly
                onClicked: swipeV.decrementCurrentIndex()
            }
            ToolButton {
                id: navForw
                y: parent.height*0.5 - height*0.5
                anchors.right: parent.right
                anchors.rightMargin: 0
                icon.source: "qrc:/icons/arrow_forward_ios-24px.svg"
                icon.color: CT.text1
                icon.height: 25*scale
                icon.width: 25*scale
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

        // TODO: move to own file
        Drawer {
            id: dMenu
            z: 2
            width: 0.8 * root.width
            height: root.height
            Material.background: CT.foregroundDark
            onClosed: toggleSettings(false)

            function toggleSettings(enable)
            {
                dContent.visible = !enable
                dSettings.visible = enable
                dSettings.forceActiveFocus()
            }

            Item {
                id: dMenuMain
                anchors.fill: parent
                ScrollView {
                    anchors.fill: parent
                    Column {
                        id: dContent
                        anchors.top: parent.top
                        anchors.topMargin: 40*scale
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        width: parent.width
                        spacing: 10*scale
                        ItemDelegate {
                            id: settingsButton
                            text: "Settings"
                            font.pixelSize: font_s*scale
                            width: dMenuMain.width
                            onClicked: dMenu.toggleSettings(true)
                        }
                        ItemDelegate {
                            id: licenseButton
                            text: "Show license"
                            font.pixelSize: font_s*scale
                            width: dMenuMain.width
                        }
                        ItemDelegate {
                            id: githubButton
                            text: "View on GitHub"
                            font.pixelSize: font_s*scale
                            width: dMenuMain.width
                        }
                    }
                }
            }
            Item {
                id: dSettings
                anchors.fill: parent
                visible: false
                ToolBar {
                    anchors.top: parent.top
                    width: parent.width
                    height: 66*scale
                    Material.background: CT.backgroundDark
                    ToolButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "qrc:/icons/arrow_back-24px.svg"
                        icon.color: CT.text1
                        icon.height: 34*scale
                        icon.width: 34*scale
                        display: AbstractButton.IconOnly
                        onClicked:{
                            dMenu.toggleSettings(false)
                        }
                    }
                    Text {
                        text: "Settings"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: font_b*scale
                        color: CT.text1
                    }
                }


                Column {
                    anchors.top: parent.top
                    anchors.topMargin: 78*scale
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    width: parent.width
                    spacing: 10*scale

                    Text {
                        text: "General:"
                        color: CT.text1
                        font.pointSize: font_m*scale
                        leftPadding: 15*scale

                    }

                    ItemDelegate {
                        text:"Measuring unit: " + cfg.unit
                        font.pixelSize: font_s*scale
                        width: parent.width
                        onClicked: contextMenu.popup()
                    }

                    Menu {
                            id: contextMenu
                            z:3
                            MenuItem {text: "Kilograms (kg)"; onClicked: cfg.unit = "kg"}
                            MenuItem { text: "Pounds (lb)"; onClicked: cfg.unit = "lb"}
                    }
                }
            }
        }
    }
}

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
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

    Alert {
        id: rootAlert
        z: 10
        y: 160*scale
    }

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

    function toggleSetsView(enabled)
    {
        addSetsView.visible = enabled
        mainViewContainer.visible = !enabled
        dMenu.interactive = !enabled

        if (enabled)
            addSetsView.updateSetElements()
        else
            view.currentItem.item.loadWosItems()
    }

    Component.onCompleted: {
        view.currentItem.item.loadWosItems()
    }

    onClosing: {
        if (addSetsView.visible)
        {
            close.accepted = false
            toggleSetsView(false)
        }
    }

    SetsView {id: addSetsView}

    // Scroll related elements for day pages
    Item {
        id: mainViewContainer
        anchors.fill: parent

        Pane {
            anchors.fill: parent
            Material.background: CT.backgroundDark
        }

        PathView {
            id: view
            anchors.fill: parent
            snapMode: PathView.SnapToItem
            model: ["dayPage.qml","dayPage.qml","dayPage.qml"]
            delegate: Loader {
                width: parent.width
                height: parent.height
                source: modelData
            }
            property var prev_index: 0

            onDragStarted: prev_index = currentIndex

            onCurrentIndexChanged:
            {
                // embarrassing if-else -statement
                if (((prev_index > currentIndex)&& !( currentIndex == 0  && prev_index == 2)) || (currentIndex == 2 && prev_index == 0))
                    dataStore.scrollDate(1)
                else if (prev_index < currentIndex || (currentIndex == 0 && prev_index == 2))
                    dataStore.scrollDate(-1)

                console.log(currentIndex)

                prev_index = currentIndex

                currentItem.item.loadWosItems()
            }

            path: Path {
                startX: view.width/2; startY: view.height/2
                PathQuad { x: view.width/2; y: view.height*view.model.length; controlX: -view.width; controlY: view.height/2 }
                PathQuad { x: view.width/2; y: view.height/2; controlX: view.width * view.model.length; controlY: view.height/2 }
            }
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
                onClicked: view.incrementCurrentIndex()
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
                onClicked: view.decrementCurrentIndex()
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
                addWOSPopup.open()
            }
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40

        }

        // Popup for adding sets / creating workout
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
            Alert {
                id: popupAlert
                z: 10
                y: 160*scale
            }

            PopupSearchPage {id: srchPage}
            PopupAddExPage {id: addxPage; visible: false}
        }

        // Settings
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
                        id:label1
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
                        MenuItem {
                            text: "Kilograms (kg)"
                            onClicked: {
                                cfg.unit = "kg"
                                view.currentItem.item.loadWosItems()
                            }
                        }
                        MenuItem {
                            text: "Pounds (lb)"
                            onClicked: {
                                cfg.unit = "lb"
                                view.currentItem.item.loadWosItems()
                            }
                        }
                    }
                }
            }
        }
    }
}

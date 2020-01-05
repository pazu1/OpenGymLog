import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
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
    property var root_scale: (height+width)/(855 + 480)
    property var exercisesDB: []
    property int font_s: 18
    property int font_m: 22
    property int font_b: 26

    Connections {
        target: dataStore
        onSelectedDateChanged: view.currentItem.item.loadWosItems()
    }

    Alert {
        id: rootAlert
        z: 10
        y: 160*root_scale
    }

    Settings {
        id: cfg
        property string unit: "kg"
        property int theme: 0
    }

    function loadTheme()
    {
        if (CT.c_themes[cfg.theme].drk)

            Material.theme = Material.Dark
        else
            Material.theme = Material.Light
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
    }

    Component.onCompleted: {
        view.currentItem.item.loadWosItems()
        loadTheme()
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
            Material.background: CT.c_themes[cfg.theme].bg1
        }

        PathView {
            id: view
            anchors.fill: parent
            snapMode: PathView.SnapOneItem
            model: ["dayPage.qml","dayPage.qml","dayPage.qml",]
            flickDeceleration: 0
            maximumFlickVelocity: 9999
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

                prev_index = currentIndex
            }

            path: Path {
                startX: view.width/2; startY: view.height/2
                PathQuad { x: view.width/2; y: view.height*2.5; controlX: -view.width; controlY: view.height/2 }
                PathQuad { x: view.width/2; y: view.height/2; controlX: view.width * view.model.length; controlY: view.height/2 }
            }
        }

        ToolBar {
            id: mainBar
            anchors.top: parent.top
            z: 1
            width: root.width
            height: 66*root_scale
            opacity: 1
            Material.background: CT.accent1

            ToolButton {
                id: dMenuButton
                anchors.left: parent.left
                anchors.leftMargin: 10*root_scale
                icon.source: "qrc:/icons/menu-24px.svg"
                icon.height: 34*root_scale
                icon.width: 34*root_scale
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
            height: 45*root_scale
            opacity: 1
            Material.background: CT.c_themes[cfg.theme].bg2

            Text {
                id: slctdDayText
                height: navigationBar.height
                color: CT.c_themes[cfg.theme].txt
                text: selectedDate.toDateString()
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: font_m*root_scale
            }

            ToolButton {
                id: navBack
                anchors.verticalCenter: parent.verticalCenter
                icon.source: "qrc:/icons/arrow_back_ios-24px.svg"
                icon.color: CT.c_themes[cfg.theme].txt
                icon.height: 25*root_scale
                icon.width: 25*root_scale
                display: AbstractButton.IconOnly
                onClicked: view.incrementCurrentIndex()
            }
            ToolButton {
                id: navForw
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 0
                icon.source: "qrc:/icons/arrow_forward_ios-24px.svg"
                icon.color: CT.c_themes[cfg.theme].txt
                icon.height: 25*root_scale
                icon.width: 25*root_scale
                display: AbstractButton.IconOnly
                onClicked: view.decrementCurrentIndex()
            }

            ToolButton {
                id: reset
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: slctdDayText.paintedWidth*0.5
                icon.source: "qrc:/icons/restore-24px.svg"
                icon.color: CT.c_themes[cfg.theme].txt
                icon.height: 25*root_scale
                icon.width: 25*root_scale
                display: AbstractButton.IconOnly
                onClicked: dataStore.selectedDate =  new Date()

            }
        }

        RoundButton {
            id: addWOSButton
            anchors.right: parent.right
            anchors.rightMargin: 40*root_scale
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30*root_scale
            width: 75*root_scale
            height: 75*root_scale
            text: "+"
            visible: true
            font.pointSize: 28
            font.bold: true
            Material.background: CT.accent1
            Material.foreground: "#000000"
            onClicked: {
                addWOSPopup.open()
            }
        }

        // Popup for adding sets / creating workout
        Popup {
            id: addWOSPopup
            x: root.width*(0.15/2)
            y: root.height*(0.15/2)
            width: root.width*0.85
            height: root.height*0.85
            Material.background: CT.c_themes[cfg.theme].bg2
            horizontalPadding: 0
            verticalPadding: 0
            clip: true
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
            Overlay.modal: Rectangle {
                    color: "#85000000"
                }
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
                y: 160*root_scale
            }

            PopupSearchPage {id: srchPage}
            PopupAddExPage {id: addxPage; visible: false}
        }

        // Drawer menu
        Drawer {
            id: dMenu
            z: 2
            width: 0.8 * root.width
            height: root.height
            Material.background: CT.c_themes[cfg.theme].bg2
            onClosed: toggleSettings(false)
            Overlay.modal: Rectangle {
                    color: "#85000000"
                }

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
                        anchors.topMargin: 40*root_scale
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        width: parent.width
                        spacing: 10*root_scale
                        ItemDelegate {
                            id: settingsButton
                            text: "Settings"
                            font.pixelSize: font_s*root_scale
                            width: dMenuMain.width
                            onClicked: dMenu.toggleSettings(true)
                        }
                        ItemDelegate {
                            id: githubButton
                            text: "View on GitHub"
                            font.pixelSize: font_s*root_scale
                            width: dMenuMain.width
                            onClicked: Qt.openUrlExternally("https://github.com/pazu1/OpenGymLog")
                        }
                        ItemDelegate {
                            id: licenseButton
                            text: "Show license (GPL v3)"
                            font.pixelSize: font_s*root_scale
                            width: dMenuMain.width
                            onClicked: Qt.openUrlExternally("https://www.gnu.org/licenses/gpl-3.0.html")
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
                    height: 66*root_scale
                    Material.background: CT.c_themes[cfg.theme].bg1
                    ToolButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "qrc:/icons/arrow_back-24px.svg"
                        icon.color: CT.c_themes[cfg.theme].txt
                        icon.height: 34*root_scale
                        icon.width: 34*root_scale
                        display: AbstractButton.IconOnly
                        onClicked:{
                            dMenu.toggleSettings(false)
                        }
                    }
                    Text {
                        text: "Settings"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: font_b*root_scale
                        color: CT.c_themes[cfg.theme].txt
                    }
                }


                Column {
                    id: settingsColumn
                    anchors.top: parent.top
                    anchors.topMargin: 78*root_scale
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 20*root_scale
                    width: parent.width
                    spacing: 10*root_scale

                    Text {
                        id:label1
                        text: "General:"
                        color: CT.c_themes[cfg.theme].txt
                        font.pointSize: font_m*root_scale
                    }
                    Row {
                        spacing: 20*root_scale

                        Text {
                            text:"Weight unit:"
                            font.pixelSize: font_s*root_scale
                            color: CT.c_themes[cfg.theme].txt
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        ComboBox {
                            z:2
                            width: settingsColumn.width*0.5
                            x:0
                            font.pixelSize: font_s*root_scale
                            model: [ "Kilograms (kg)", "Pounds (lb)"]
                            popup.z: 2
                            onCurrentIndexChanged: {
                                if (currentIndex == 0)
                                    cfg.unit = "kg"
                                else
                                    cfg.unit = "lb"
                                if (view.currentItem != null)
                                    view.currentItem.item.loadWosItems()
                            }
                        }
                    }
                    Row {
                        spacing: 20*root_scale

                        Text {
                            text:"Theme:"
                            font.pixelSize: font_s*root_scale
                            color: CT.c_themes[cfg.theme].txt
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        ComboBox {
                            Component.onCompleted: currentIndex = cfg.theme
                            z:2
                            width: settingsColumn.width*0.5
                            x:0
                            font.pixelSize: font_s*root_scale
                            model: [ "Dark", "Light"]
                            popup.z: 2
                            onCurrentIndexChanged: {
                                cfg.theme = currentIndex
                                root.loadTheme()
                            }
                        }
                    }
                }
            }
        }
    }
}

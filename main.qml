import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import com.pz.exercise 1.0

ApplicationWindow {
    id: root
    width: 480
    height: 855
    color: "#000000"
    visible: true
    title: qsTr("QML&C++")
    Material.theme: Material.Dark
    Material.accent: Material.Purple
    property var scale_factor: (width+height)/(480+855)
    property var scale_y: height/855
    property var scale_x: width/480


    /*Connections {
        // On sataStore's signal 'increaseOne' do txtCount.txt = ms
        target: dataStore
        onIncreaseOne: txtCount.text = ms // ms = parameter of 'increaseOne'
    }*/

    /*
    Column {
        id: firstColumn
        Text {
            id: txtCount
            text: dataStore.message // updated when ever messageChanged is emitted
            // -> READs by calling message (getter)
        }

        Button {
            id: btnUpdate
            text: "click me"
            onClicked: dataStore.callMeFromQml() // calls a void slot, no parameters; else you need Q_INVOKABLE
        }
    }

    Column {
        anchors.left: firstColumn.right
        TextEdit {
            id: txtEdit
            height: txtCount.height
            width: btnEdit.width
        }

        Button {
            id: btnEdit
            text: "update property"
            onClicked: dataStore.message = txtEdit.text // WRITEs by calling setMessage (setter)
        }

        Button {
            text: "Q_INVOKABLE"
            onClicked: {
                var result = dataStore.qInvokeExample("This is passed from QML to c++");
                console.log("Result got from c++ to QML " + result)
            }
        }
    }*/

    Item {id: addSetsView; width: root.width; height:root.height
        visible: false
        property var exercise_name: "add new"


        Pane {
            id: pane
            width: root.width
            height: repsField.y+repsField.height
        }

        ToolBar {
            id: toolBar
            x: 0
            y: 0
            width: root.width
            height: 66*scale_y
            Material.background: Material.Purple

            Text {
                id: element
                x: 0
                y: 0
                width: toolBar.width
                height: toolBar.height
                color: "#000000"
                text: addSetsView.exercise_name
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 22*scale_y
            }
        }

        Text {
            id: wText
            x: weightField.x-width*0.7
            y: weightField.y
            width: 120*scale_x
            height: 40*scale_y
            color: "#959694"
            text: qsTr("weight:")
            styleColor: "#d0a2a2"
            font.pixelSize: 22
        }

        Text {
            id: rText
            x: repsField.x-width*0.7
            y: repsField.y
            width: 120*scale_x
            height: 40*scale_y
            color: "#959694"
            text: qsTr("reps:")
            font.pixelSize: 22
        }

        TextField {
            id: weightField
            x: 200*scale_x
            y: 120*scale_y
            width: 80
            height: 40*scale_y
            text: qsTr("")
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }

        TextField {
            id: repsField
            x: 200*scale_x
            y: 160*scale_y
            width: 80
            text: qsTr("")
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }

        Button {
            id: setAddButton
            x: 346*scale_x
            y: repsField.y-height*0.3
            width: 107*scale_x
            height: 55*scale_y
            text: qsTr("Add set")
        }



    }

    Item {id: mainView; width: root.width; height:root.height
        Popup {
            id: addWOSPopup
            x: root.width*(0.15/2)
            y: root.height*(0.15/2)
            width: root.width*0.85
            height: root.height*0.85
            horizontalPadding: 1
            verticalPadding: 1
            clip: true
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
            onOpened: searchItemsColumn.populateWithItems()

            TextField {
                id: searchField

                text: ""
                width: addWOSPopup.width
                height: addWOSPopup.height*0.07
                placeholderText: " type to search"

                onTextEdited:
                    searchItemsColumn.searchParse(text)
            }

            TabBar {
                id: tabBar
                y: addWOSPopup.height-height
                position: TabBar.Footer
                width: addWOSPopup.width
                anchors.bottom: addWOSPopup.bottom
                TabButton {
                    id: cancelButton
                    text: "Cancel"
                    hoverEnabled: false
                    onClicked:
                        addWOSPopup.close()
                }
            }

            ScrollView {
                id: popupScrollView
                width: parent.width
                y: searchField.height
                height: parent.height-cancelButton.height-searchField.height
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                Component {
                    id: createdSearchItem

                    ItemDelegate {
                        id: itemRoot
                        width: searchItemsColumn.width
                        height: searchItemsColumn.height*0.07
                        property var name: "none"
                        function setName(new_name){
                            name = new_name
                        }
                        text: name
                        onClicked: {
                            mainView.visible = false
                            addSetsView.visible = true
                            addSetsView.exercise_name = itemRoot.name
                            // TODO:
                            // create C++ object for this exercise on this date
                            // upon opening addSetsView, retrieve created object from C++
                            addWOSPopup.close()
                        }
                    }
                }

                Column {
                    id: searchItemsColumn
                    width: popupScrollView.width
                    height: popupScrollView.height

                    function populateWithItems() {

                        // Clear items first
                        searchItemsColumn.children = [] // TODO: this shit dont work

                        // Load and create new items
                        for(var i = 0; i<dataStore.getExerciseAmount(); i++){
                            var search_item = createdSearchItem.createObject(searchItemsColumn)
                            /*
                        var component = Qt.createComponent("exrcNameSearchItem.qml")
                        component.createObject(searchItemsColumn)*/
                        }
                        for (var n = 0; n < children.length; n++)
                        {
                            children[n].setName(dataStore.getExerciseAt(n).getName())
                        }


                        popupScrollView.clip = true
                    }

                    function searchParse(search_word)
                    {
                        for(var i = searchItemsColumn.children.length; i > 0 ; i--) {
                            searchItemsColumn.children[i-1].visible = true
                            if (!searchItemsColumn.children[i-1].name.includes(search_word))
                                searchItemsColumn.children[i-1].visible = false
                        }
                    }
                }
            }
        }

        ScrollView {
            id: scrollView
            x: 12
            width: root.width*0.95
            anchors.topMargin: root.height*0.065
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            anchors.bottomMargin: 0
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            Column {
                id: columnWosItems
                width: scrollView.width
                height: scrollView.height
            }
        }

        RoundButton {
            id: addWOSButton
            x: 338
            y: 584
            width: 75*root.scale_factor
            height: 75*root.scale_factor
            text: "+"
            visible: true
            font.pointSize: 28
            font.bold: true
            onClicked: {
                addWOSPopup.open()

                var component = Qt.createComponent("wosItem.qml")
                component.createObject(columnWosItems)
                //component.Material.theme = root.theme*/
            }
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40

        }

    }

}

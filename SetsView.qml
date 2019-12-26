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
    visible: false

    property string exercise_name: "add new"
    property var sets: []

    onVisibleChanged: {
        if (visible)
            pageTEMP.makeGraph(exercise_name)
    }

    function loadAddSetsPage(){
        page1.clearSets()
        page1.loadSets()
    }
    Pane {
        width: root.width
        height: root.height
        Material.background: CT.backgroundDark
    }

    SwipeView {
        id: swipeLogGraph
        anchors.fill: parent
        currentIndex: 0

        onCurrentIndexChanged:
        {
            if (currentIndex === 0)
                logButton.toggle()
            else
                graphButton.toggle()
        }
        AddSetsPage{ id: page1 }
        GraphPage{ id: pageTEMP }

    }

    TabBar {
        id: tabBarAS
        y: addSetsView.height-height
        position: TabBar.Footer
        width: addSetsView.width
        anchors.bottom: addSetsView.bottom
        anchors.bottomMargin: 0
        Material.background: CT.foregroundDark
        TabButton {
            id: logButton
            text: "log"
            hoverEnabled: false
            onToggled: swipeLogGraph.currentIndex = 0
        }
        TabButton {
            id: graphButton
            text: "graph"
            hoverEnabled: false
            onToggled: swipeLogGraph.currentIndex = 1

        }
    }

    ToolBar {
        id: toolBarAS
        x: 0
        y: 0
        width: root.width
        height: 66*scale_y
        Material.background: CT.accent1
        ToolButton {
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "qrc:/icons/arrow_back-24px.svg"
            icon.color: "#000000"
            icon.height: 34*scale
            icon.width: 34*scale
            display: AbstractButton.IconOnly
            onClicked:{
                toggleSetsView(false)
            }

        }

        Text {
            id: element
            x: 0
            y: 0
            width: toolBarAS.width
            height: toolBarAS.height
            color: "#000000"
            text: addSetsView.exercise_name
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: font_b*scale
        }
    }
}

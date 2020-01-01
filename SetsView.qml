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

    function updateSetElements(){
        page1.clearSets()
        page1.loadSets()
        page2.makeGraph(exercise_name)
    }
    Pane {
        width: root.width
        height: root.height
        Material.background: CT.c_themes[cfg.theme].bg1
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
        GraphPage{ id: page2 }

    }

    TabBar {
        id: tabBarAS
        y: addSetsView.height-height
        position: TabBar.Footer
        width: addSetsView.width
        anchors.bottom: addSetsView.bottom
        anchors.bottomMargin: 0
        Material.background: CT.c_themes[cfg.theme].bg2
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
        height: 66*root_scale
        Material.background: CT.accent1
        ToolButton {
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "qrc:/icons/arrow_back-24px.svg"
            icon.color: "#000000"
            icon.height: 34*root_scale
            icon.width: 34*root_scale
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
            font.pixelSize: font_b*root_scale
        }
    }
}

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import QtCharts 2.3
import Qt.labs.settings 1.0
import com.pz.exercise 1.0
import com.pz.singleset 1.0
import com.pz.workout 1.0
import "Constants.js" as CT

Item { 
    id: itemRoot
    property var dates: []
    property var clicked_btn_origin: Qt.point(0,0)
    property var selected_y_value
    property var selected_day
    property var graph_type: 0
    clip: true

    onVisibleChanged: {
        if (!visible)
            pointInfoPopup.close()
    }

    function makeGraph(ex_name)
    {
        var maxes = []
        var highest = []
        highest = 0
        axisX.max = 1
        axisY.max = 1

        line.removePoints(0,line.count) // empty graph

        maxes = []
        maxes = dataStore.getGraphValues(ex_name, graph_type)

        var days = []
        days = dataStore.getDaysOfExercise(ex_name)
        dates = dataStore.getDaysOfExercise(ex_name, false)

        if (dates.length == 0 || days.length < 2)
        {
            chart.visible = false
            issueText.visible = true
            return
        }
        issueText.visible = false
        chart.visible = true

        var day = 0
        for (var i = 0; i< maxes.length; i++)
        {
            line.append(days[i], maxes[i])
            if (maxes[i] > highest)
                highest = maxes[i]
            day = days[i]
        }
        axisX.max = day
        axisY.max = highest*1.1

        dayFirst.text = dates[0].toLocaleString(Qt.locale("en_EN"),"dd MMM yy")
        dayLast.text = dates.slice(-1)[0].toLocaleString(Qt.locale("en_EN"),"dd MMM yy")
        axisY.applyNiceNumbers()

        line.makeLineButtons()
    }

    Text {
        id: issueText
        text: qsTr("Not enough records on this exercise to display a graph.")
        font.pixelSize: font_s*root_scale
        width: root.width
        wrapMode: Text.WordWrap
        visible: false
        color: CT.c_themes[cfg.theme].txt
        horizontalAlignment: Text.AlignHCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    ToolBar {
        Material.background: CT.c_themes[cfg.theme].bg2
        anchors.top: parent.top
        anchors.topMargin: 66*root_scale
        height: 45*root_scale
        width: parent.width
        RoundButton {
            text: "▼"
            Material.background: "#00000000"
            anchors.right: parent.right
            anchors.rightMargin: 10*root_scale
            anchors.verticalCenter: parent.verticalCenter
            onClicked: comboMenu.open()
        }

        Text {
            id: graphTypeHeader
            text: "Estimated 1 Rep Max"
            font.pixelSize: font_m*root_scale
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: CT.c_themes[cfg.theme].txt
            onTextChanged: itemRoot.makeGraph(exercise_name)
        }

        Menu {
            id: comboMenu
            padding: 0
            width: parent.width
            y: parent.y+parent.height
            MenuItem { text: "Estimated 1 Rep Max"; onClicked: {graph_type = 0; graphTypeHeader.text = text}}
            MenuItem { text: "Total Volume"; onClicked: {graph_type = 1; graphTypeHeader.text = text}}
            MenuItem { text: "Highest weight"; onClicked: graphTypeHeader.text = text}
        }
    }

    ChartView {
        id: chart
        height: parent.height*0.55
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        title: ""
        legend.visible: false
        backgroundColor: "#00000000"
        plotAreaColor: CT.c_themes[cfg.theme].abs
        backgroundRoundness: 0
        antialiasing: true

        Component {
            id: createdButton
            RoundButton {
                height: 40*root_scale
                width: 40*root_scale
                opacity: 0
                property var point
                property var date
                function setProps(contained_point, contained_day){
                    point = contained_point
                    date = contained_day
                    x = chart.mapToPosition(point,line).x-width*0.5
                    y = chart.mapToPosition(point,line).y-height*0.5
                }
                onClicked: {
                    selected_y_value = ((point.y*100) / 100).toFixed(2);
                    selected_day = date
                    clicked_btn_origin = itemRoot.mapFromItem(chart,x+width*0.5,y+height*0.5)
                    pointInfoPopup.open()
                }
            }
        }

        Item {
            id: lineButtons
            anchors.fill: parent

        }

        LineSeries {
            id: line
            axisX: axisX
            axisY: axisY
            color: CT.accent1
            pointsVisible: true
            width: 3*root_scale

            function makeLineButtons() {

                for(var c = lineButtons.children.length; c > 0 ; c--) {
                    lineButtons.children[c-1].destroy()
                }

                for (var n = 0 ; n<count ; n++) {
                    var pointButton = createdButton.createObject(lineButtons)
                    pointButton.setProps(at(n),dates[n])
                }
            }
        }

        ValueAxis {
            id: axisX
            min: 0
            max: 10
            gridVisible: false
            labelsVisible: false
            color: CT.accent1
            tickCount: 2
        }
        ValueAxis {
            id: axisY
            min: 0
            max: 250
            tickCount: 6
            gridVisible: false
            color: CT.accent1
            labelFormat: "%.0f "+ cfg.unit
            labelsColor: CT.c_themes[cfg.theme].txt
        }
        Text {
            id: dayFirst
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 25*root_scale
            anchors.top: chart.bottom
            anchors.topMargin: -23*root_scale
            color: CT.c_themes[cfg.theme].txt
            font.pixelSize: font_s*root_scale
        }
        Text {
            id: dayLast
            text: ""
            anchors.right: parent.right
            anchors.rightMargin: 25*root_scale
            anchors.top: chart.bottom
            anchors.topMargin: -23*root_scale
            color: CT.c_themes[cfg.theme].txt
            font.pixelSize: font_s*root_scale
        }
    }

    Popup {
        id: pointInfoPopup
        y: parent.height*0.4
        x: parent.width*0.5-width*0.5
        width: 300*root_scale
        height: 180*root_scale
        Material.background: CT.c_themes[cfg.theme].bg3
        padding: 0
        onAboutToShow: {
            title.text = selected_day.toDateString()
            y = clicked_btn_origin.y - 100*root_scale - height
            cnvs.visible = true
            cnvs.requestPaint()
        }
        onAboutToHide: {
            cnvs.opacity = 0
            cnvs.visible = false
        }

        Text {
            id: title
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10*root_scale
            text: qsTr("")
            font.pixelSize: font_m*root_scale
            font.bold: true
            color: CT.c_themes[cfg.theme].b_txt
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height*0.3
            text: qsTr(graphTypeHeader.text +": "+selected_y_value+" "+cfg.unit)
            font.pixelSize: font_s*root_scale
            color: CT.c_themes[cfg.theme].txt
        }
        MouseArea {
            id: dragArea
            anchors.fill: parent
            property point lastMousePos: Qt.point(0, 0)
            onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
            onMouseXChanged: {
                if ( pointInfoPopup.x+pointInfoPopup.width+(mouseX - lastMousePos.x) <= root.width
                     && pointInfoPopup.x+(mouseX - lastMousePos.x)>0 )
                {
                    pointInfoPopup.x += (mouseX - lastMousePos.x)
                    cnvs.requestPaint()
                }
            }
            onMouseYChanged: {
                if ( pointInfoPopup.y+pointInfoPopup.height+(mouseY - lastMousePos.y) <= root.height
                     && pointInfoPopup.y+(mouseY - lastMousePos.y)>0 )
                {
                    pointInfoPopup.y += (mouseY - lastMousePos.y)
                    cnvs.requestPaint()
                }
            }
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: 10*root_scale
            anchors.leftMargin: 10*root_scale
            text: "View workout"
            onClicked: {
                swipeLogGraph.currentIndex = 0
                dataStore.selectedDate = selected_day
                root.toggleSetsView(true)
            }
        }
    }

    Canvas {
        id: cnvs
        opacity: 0
        z: 3
        anchors.fill: parent
        visible: false
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Cooperative
        property var startOnTop: false
        onVisibleChanged: {
            if (visible)
                anim.start()
        }

        OpacityAnimator {
            id: anim
            target: cnvs
            from: 0
            to: 1
            duration: 300
            running: false
        }

        onPaint: {
            var context = getContext("2d")
            context.reset()

            context.beginPath();
            context.moveTo(clicked_btn_origin.x,clicked_btn_origin.y)
            context.lineTo(pointInfoPopup.x+pointInfoPopup.width*0.4, pointInfoPopup.y+pointInfoPopup.height*0.5)
            context.lineTo(pointInfoPopup.x+pointInfoPopup.width*0.6, pointInfoPopup.y+pointInfoPopup.height*0.5)
            context.closePath()

            context.fillStyle = CT.c_themes[cfg.theme].bg3
            context.fill()
        }
    }
}


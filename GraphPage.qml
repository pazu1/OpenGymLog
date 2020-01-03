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

        line.removePoints(0,line.count) // empty graph

        maxes = []
        maxes = dataStore.getEstOneRepMaxes(ex_name)

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
        axisY.max = highest+(highest/4)
        axisY.applyNiceNumbers()

        dayFirst.text = dates[0].toLocaleString(Qt.locale("en_EN"),"dd MMM yy")
        dayLast.text = dates.slice(-1)[0].toLocaleString(Qt.locale("en_EN"),"dd MMM yy")

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
        Text {
            text: "Estimated 1 Rep Max"
            font.pixelSize: font_m
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: CT.c_themes[cfg.theme].txt
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

    Dialog {
        id: pointInfoPopup
        title: ""
        y: parent.height*0.4
        x: parent.width*0.5-width*0.5
        width: 300*root_scale
        height: 200*root_scale
        Material.background: CT.c_themes[cfg.theme].bg3
        onAboutToShow: {
            title = selected_day.toDateString()
            y = clicked_btn_origin.y - 100*root_scale - height
            cnvs.visible = true
            cnvs.requestPaint()
        }
        onAboutToHide: {
            cnvs.opacity = 0
            cnvs.visible = false
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Estimated 1 Rep Max: "+selected_y_value+" "+cfg.unit)
            font.pixelSize: font_s*root_scale
            color: CT.c_themes[cfg.theme].txt
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -10*root_scale
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
            context.lineTo(pointInfoPopup.x+pointInfoPopup.width*0.4, pointInfoPopup.y+pointInfoPopup.height-20*root_scale)
            context.lineTo(pointInfoPopup.x+pointInfoPopup.width*0.6, pointInfoPopup.y+pointInfoPopup.height-20*root_scale)
            context.closePath()

            context.fillStyle = CT.c_themes[cfg.theme].bg3
            context.fill()
        }
    }
}


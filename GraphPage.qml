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
    property var dates: []
    property var line
    clip: true

    function makeGraph(ex_name)
    {
        var maxes = []
        var highest = []
        highest = 0
        if (chart.count == 0)
        {
            chart.createSeries(ChartView.SeriesTypeLine,"test",axisX,axisY)
            line = chart.series(0)
            line.color = CT.accent1
            line.pointsVisible = true
        }
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
    }

    Text {
        id: issueText
        text: qsTr("Not enough records on this exercise to display a graph.")
        font.pixelSize: font_s*root_scale
        visible: false
        color: CT.text1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    ToolBar {
        Material.background: CT.backgroundDark
        anchors.top: parent.top
        anchors.topMargin: 66*root_scale
        height: 45*root_scale
        width: parent.width
        Text {
            text: "Estimated 1 Rep Max"
            font.pixelSize: font_m
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: CT.text1
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
        plotAreaColor: "#000000"
        backgroundRoundness: 0
        antialiasing: true

        ValueAxis {
            id: axisX
            min: 0
            max: 10
            gridVisible: false
            labelsVisible: false
            tickCount: 2
        }
        ValueAxis {
            id: axisY
            min: 0
            max: 250
            tickCount: 6
            gridVisible: false
            labelFormat: "%.0f "+ cfg.unit
            labelsColor: CT.text1
        }
        Text {
            id: dayFirst
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 25*root_scale
            anchors.top: chart.bottom
            anchors.topMargin: -23*root_scale
            color: CT.text1
            font.pixelSize: font_s*root_scale
        }
        Text {
            id: dayLast
            text: ""
            anchors.right: parent.right
            anchors.rightMargin: 25*root_scale
            anchors.top: chart.bottom
            anchors.topMargin: -23*root_scale
            color: CT.text1
            font.pixelSize: font_s*root_scale
        }
    }
}


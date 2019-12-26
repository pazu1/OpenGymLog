import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12
import QtCharts 2.3
import Qt.labs.settings 1.0
import com.pz.exercise 1.0
import com.pz.singleset 1.0
import com.pz.workout 1.0
import "Constants.js" as CT

Item {
    property var maxes: []
    property var highest

    function makeGraph(ex_name)
    {
        highest = 0
        if (chart.count == 0)
        {
            chart.createSeries(ChartView.SeriesTypeLine,"test",axisX,axisY)
        }
        var line = chart.series(0)
        line.color = CT.accent1
        line.removePoints(0,line.count)
        line.pointsVisible = true

        maxes = []
        maxes = dataStore.getEstOneRepMaxes(ex_name)
        axisX.max = maxes.length

        var days = []
        days = dataStore.getDaysOfExercise(ex_name)

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
    }

    ChartView {
        id: chart
        height: parent.height*0.4
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        title: ""
        legend.visible: false
        backgroundColor: CT.backgroundDark
        plotAreaColor: "#000000"
        backgroundRoundness: 0
        antialiasing: true


        ValueAxis {
                id: axisX
                min: 0
                max: 10
                gridVisible: false
                labelFormat: "%.0f"
                labelsColor: CT.text1
        }
        ValueAxis {
                id: axisY
                min: 0
                max: 250
                tickCount: 8
                gridVisible: false
                labelFormat: "%.0f"
                labelsColor: CT.text1
        }

    }
}


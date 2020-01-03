import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import "Constants.js" as CT

Item {
    id: alertRoot
    height: 0
    width: root.width*0.98
    anchors.horizontalCenter: parent.horizontalCenter
    visible: false
    property var expanded: false

    states: [
        State {
            name: "normal"
            when: !expanded
            PropertyChanges {target: alertRoot; height: 0}
        },
        State {
            name: "expanded"
            when: expanded
            PropertyChanges {target: alertRoot; height: 40*root_scale}
        }

    ]
    transitions: Transition {
                 PropertyAnimation { property: "height"; duration: 200; easing.type: Easing.InOutQuad; onFinished: animation.start() }
    }


    function showAlert(deploy_point, is_error, message)
    {
        if (delayedAnimation.running || animation.running)
            return
        visible = true
        if (is_error)
            opacityRect.color = CT.RED
        else
            opacityRect.color = CT.GREEN
        messageTxt.text = message
        delayedAnimation.start()
        expanded= true
        y = deploy_point+2*root_scale
    }

    Rectangle {
        id: opacityRect
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 3
        color: CT.GREEN
        Text {
            id: messageTxt
            text: qsTr("Alert!")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: font_s*root_scale
        }
    }

    OpacityAnimator {
        id: delayedAnimation
        target: opacityRect;
        from: 1;
        to: 1;
        duration: 2000
        running: false
        onFinished: animation.start()
    }

    OpacityAnimator {
        id: animation
        target: opacityRect;
        from: 1;
        to: 0;
        duration: 1300
        running: false
        onFinished: {
            alertRoot.visible = false
            expanded = false
        }
    }

}

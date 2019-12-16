import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import com.pz.singleset 1.0
import "Constants.js" as Constants


Item {
    id: singleSetBarRoot
    width: 200
    height: 60
    function setProps(containedSet) {
        baseItem.text = containedSet.getAmount()+"x"+containedSet.getReps()+"   "+containedSet.getWeight()+" kg"

    }
    Pane {
        id: pane
        x: 0
        y: 0
        Material.background: Constants.foregroundDark
        width: singleSetBarRoot.width
        height: singleSetBarRoot.height
    }

    ItemDelegate {
        id: baseItem
        width: singleSetBarRoot.width
        height: singleSetBarRoot.height
        text: "none"
        font.pixelSize: 22*scale_x
    }
}

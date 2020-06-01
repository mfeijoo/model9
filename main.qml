import QtQuick 2.0
import QtQuick.Window 2.10
import QtQuick.Extras 1.4
import QtQuick.VirtualKeyboard 2.1
import QtQuick.Controls 2.3

Window {
    id: window
    visible:true
    width: 1920
    height: 1012

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: mainMenu
    }

    Component {
        id: mainMenu
        Bottom {
            text: "Push"
            oncliked
        }


    }

}

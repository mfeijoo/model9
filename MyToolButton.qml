import QtQuick 2.0
import QtQuick.Controls 1.4

ToolButton {

    height: 100
    width: 100

    Image{

        source: parent.iconSource
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        anchors.margins: 10
        anchors.bottomMargin: 30
    }

    Text{
        text: parent.text
        anchors.bottom: parent.bottom
        anchors.margins: 2
        anchors.horizontalCenter: parent.horizontalCenter
        renderType: Text.NativeRendering
    }
}


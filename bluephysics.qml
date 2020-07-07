import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Window 2.10
import QtCharts 2.2
import QtQuick.Layouts 1.3


ApplicationWindow {
    id: mainwindow
    objectName: 'mainapplication'
    width: Screen.width/2
    height: Screen.height/2
    title: " Blue Physics v. 9.0.1"
    visible: true

    Item {
        id: mainmenu
        anchors.fill: parent

        Image {
            id: image
            width: 850
            height: 300
            anchors.top : parent.top
            anchors.topMargin: 200
            anchors.horizontalCenter: parent.horizontalCenter
            source: "iconspd/bluephysicslogofrompdf.jpg"
            fillMode: Image.PreserveAspectFit
        }

        Button {
            id: metadatabutton
            width: 125
            height: 125
            hoverEnabled: true
            anchors.top: image.bottom
            anchors.topMargin: 80
            anchors.horizontalCenter: parent.horizontalCenter
            icon.source: "iconspd/settings.png"
            icon.color: 'transparent'
            icon.height: 100
            icon.width: 100
            text: "Metadata"
            font.pointSize: 12
            display: AbstractButton.TextUnderIcon
            background: Rectangle {
                color:  metadatabutton.hovered ? "aliceblue" : "transparent"
            }
        }

        Button {
            id: measurebutton
            width: 125
            height: 125
            hoverEnabled: true
            text: "Measure"
            font.pointSize: 12
            anchors.right: metadatabutton.left
            anchors.rightMargin: 80
            icon.source: "iconspd/measure.png"
            icon.height: 100
            anchors.top: image.bottom
            anchors.topMargin: 80
            display: AbstractButton.TextUnderIcon
            icon.width: 100
            icon.color: 'transparent'
            background: Rectangle {
                color: measurebutton.hovered ? "aliceblue" : 'transparent'
            }
            onClicked: {
                measureview.visible = true
                mainmenu.visible = false
            }
        }

        Button {
            id: turnoffbutton
            width: 125
            height: 125
            text: "Turn Off"
            anchors.left: metadatabutton.right
            hoverEnabled: true
            anchors.leftMargin: 80
            icon.source: "iconspd/turnoff.png"
            icon.height: 100
            anchors.top: image.bottom
            font.pointSize: 12
            anchors.topMargin: 80
            display: AbstractButton.TextUnderIcon
            icon.width: 100
            icon.color: "#00000000"
            background: Rectangle {
                color: turnoffbutton.hovered ? "aliceblue" : 'transparent'
            }
            onClicked: Qt.quit()
        }
    }

    Item {
        id: measureview
        anchors.fill: parent
        visible: false


        Rectangle {
            id: rectangle
            x: 1136
            width: 150
            color: "transparent"
            z: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Button {
                id: backtomainmenubutton
                width: 125
                height: 100
                anchors.top: parent.top
                anchors.topMargin: 6
                hoverEnabled: true
                text: 'Main Menu'
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "iconspd/home.png"
                icon.height: 90
                font.pointSize: 12
                display: AbstractButton.TextUnderIcon
                icon.width: 90
                icon.color: "#00000000"
                background: Rectangle {
                    color: backtomainmenubutton.hovered ? "aliceblue" : 'transparent'
                }
                onClicked: {
                    measureview.visible = false
                    mainmenu.visible = true
                }
            }

            GroupBox {
                id: groupboxpowersupply
                title: 'PS'
                anchors.top: backtomainmenubutton.bottom
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 6
                height: 210

                ToolButton {
                    id: psonoff
                    text: psonoff.checked ? 'on' : 'off'
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    checkable: true
                    checked: true
                    height: 50
                    hoverEnabled: true
                    background: Rectangle {
                        color: (psonoff.hovered & !psonoff.checked) ? 'aliceblue'
                               : (psonoff.checked) ? 'lightskyblue' : 'transparent'
                    }
                }

                SpinBox {
                    id: psspinbox
                    from: 5600
                    value: 5759
                    to: 6000
                    objectName: 'psspinbox'
                    stepSize: 1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: psonoff.bottom
                    anchors.topMargin: 6
                    font.pointSize: 10
                    editable: true

                    property int decimals: 2
                    property real realValue: value / 100

                    validator: DoubleValidator {
                        bottom: Math.min(psspinbox.from, psspinbox.to)
                        top: Math.max(psspinbox.from, psspinbox.to)
                    }

                    textFromValue: function(value, locale) {
                        return Number(value / 100).toLocaleString(locale, 'f', psspinbox.decimals)
                    }

                    valueFromText: function(text, locale) {
                        return Number.fromLocaleString(locale, txt) * 100
                    }
                 }

                ToolButton {
                    id: regulatebutton
                    objectName: 'regulatebutton'
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: psspinbox.bottom
                    anchors.topMargin: 6
                    height: 50
                    text: 'Regulate'
                    hoverEnabled: true
                    checkable: true
                    background: Rectangle {
                        color: (regulatebutton.hovered & !regulatebutton.checked) ? 'aliceblue'
                               : (regulatebutton.checked) ? 'lightskyblue' : 'transparent'
                    }

                }

                ProgressBar {
                    id: regulateprogress
                    objectName: 'regulateprogressbar'
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: regulatebutton.bottom
                    anchors.topMargin: 6
                    from: 0
                    to: 13
                }
            }

            GroupBox {
                id: groupboxdarkcurrent
                title: 'Dark Current'
                anchors.top: groupboxpowersupply.bottom
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 6
                height: 110

                Button {
                    id: subtractdc
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    hoverEnabled: true
                    text: 'Subtract'
                    height: 50
                    background: Rectangle {
                        color: subtractdc.hovered ? "aliceblue" : 'transparent'
                    }
                }

                ProgressBar {
                    id: adcprogress
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: subtractdc.bottom
                    anchors.topMargin: 6
                }


            }



            Button{
                id: startbutton
                objectName: "startbutton"
                width: 125
                height: 50
                anchors.top: groupboxdarkcurrent.bottom
                anchors.topMargin: 6
                hoverEnabled: true
                checkable: true
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "iconspd/Play-100.png"
                display: AbstractButton.IconOnly
                icon.height: 45
                icon.width: 45
                icon.color: "#00000000"
                background: Rectangle {
                    color: startbutton.hovered ? 'aliceblue'
                           : startbutton.checked ? 'lightskyblue' :  'transparent'
                }
                onClicked: {
                    linech0.clear()
                    linech1.clear()
                    linech2.clear()
                    linech3.clear()
                    linech4.clear()
                    linech5.clear()
                    linech6.clear()
                    linech7.clear()
                    linetemp.clear()
                    startbutton.enabled = false
                    stopbutton.enabled = true
                }
            }

            Button {
                id: stopbutton
                enabled: false
                objectName: "stopbutton"
                width: 125
                height: 50
                anchors.top: startbutton.bottom
                anchors.topMargin: 6
                hoverEnabled: true
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "iconspd/Stop-100.png"
                display: AbstractButton.IconOnly
                icon.height: 45
                icon.width: 45
                icon.color: "#00000000"
                background: Rectangle {
                    color: stopbutton.hovered ? 'aliceblue' : 'transparent'
                }
                onClicked: {
                    startbutton.enabled = true
                    startbutton.checked = false
                    stopbutton.enabled = false
                }
            }

            GroupBox {
                id: groupboxplot1
                title: 'Plot1'
                anchors.top: stopbutton.bottom
                anchors.topMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.left: parent.left
                height: 250

                GridLayout {
                    rows: 4
                    columns: 2
                    anchors.fill: parent

                    ToolButton {
                        id: ch0view
                        text: 'ch0'
                        checkable: true
                        hoverEnabled: true
                        checked: true
                        background: Rectangle {
                            color: (ch0view.hovered & !ch0view.checked) ? 'aliceblue'
                                   : (ch0view.checked) ? 'lightskyblue' : 'transparent'
                        }
                    }

                   ToolButton {
                        id: ch1view
                        text: 'ch1'
                        checkable: true
                        checked: true
                        hoverEnabled: true
                        background: Rectangle {
                            color: (ch1view.hovered & !ch1view.checked) ? 'aliceblue'
                                   : (ch1view.checked) ? 'lightskyblue' : 'transparent'
                        }
                   }

                    ToolButton {
                        id: ch2view
                        text: 'ch2'
                        checkable: true
                        hoverEnabled: true
                        background: Rectangle {
                            color: (ch2view.hovered & !ch2view.checked) ? 'aliceblue'
                                   : (ch2view.checked) ? 'lightskyblue' : 'transparent'
                        }
                    }

                    ToolButton {
                        id: ch3view
                        text: 'ch3'
                        checkable: true
                        hoverEnabled: true
                        background: Rectangle {
                            color: (ch3view.hovered & !ch3view.checked) ? 'aliceblue'
                                   : (ch3view.checked) ? 'lightskyblue' : 'transparent'
                        }
                    }

                    ToolButton {
                        id: ch4view
                        text: 'ch4'
                        checkable: true
                        hoverEnabled: true
                        background: Rectangle {
                            color: (ch4view.hovered & !ch4view.checked) ? 'aliceblue'
                                   : (ch4view.checked) ? 'lightskyblue' : 'transparent'
                        }
                    }

                    ToolButton {
                        id: ch5view
                        text: 'ch5'
                        checkable: true
                        hoverEnabled: true
                        background: Rectangle {
                            color: (ch5view.hovered & !ch5view.checked) ? 'aliceblue'
                                   : (ch5view.checked) ? 'lightskyblue' : 'transparent'
                        }
                    }

                    ToolButton {
                        id: ch6view
                        text: 'ch6'
                        checkable: true
                        hoverEnabled: true
                        background: Rectangle {
                            color: (ch6view.hovered & !ch6view.checked) ? 'aliceblue'
                                   : (ch6view.checked) ? 'lightskyblue' : 'transparent'
                        }
                    }

                    ToolButton {
                        id: ch7view
                        text: 'ch7'
                        checkable: true
                        hoverEnabled: true
                        background: Rectangle {
                            color: (ch7view.hovered & !ch7view.checked) ? 'aliceblue'
                                   : (ch7view.checked) ? 'lightskyblue' : 'transparent'
                        }
                    }
                }
            }

            GroupBox {
                id: groupboxplot2iew
                title: 'Plot2'
                anchors.top: groupboxplot1.bottom
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 6
                height: 100

                ComboBox {
                    id: plot2combobox
                    anchors.fill: parent
                    model: ['None', 'Temp', '5V', 'PS', '-12V', 'Vref']
                }
            }
        }

        ChartView {
            id: chartviewchs
            anchors.top: parent.top
            anchors.bottom: chartviewpowersholder.top
            anchors.left: parent.left
            anchors.right: rectangle.left
            antialiasing: false
            theme: ChartView.ChartThemeDark

            ValueAxis {
                id: axisXch
                min: 0
                max: 60
                titleText: 'Time (s)'
            }

            ValueAxis {
                id: axisYch
                min: -0.05
                max: 1
                titleText: 'Voltage (V)'
            }

            LineSeries {
                id: linech0
                name: 'ch0'
                color: 'red'
                useOpenGL: true
                axisX: axisXch
                axisY: axisYch
                visible: ch0view.checked
            }
            LineSeries {
                id: linech1
                name: 'ch1'
                color: 'lightblue'
                useOpenGL: true
                axisX: axisXch
                axisY: axisYch
                visible: ch1view.checked
            }
            LineSeries {
                id: linech2
                name: 'ch2'
                color: 'lightgreen'
                useOpenGL: true
                axisX: axisXch
                axisY: axisYch
                visible: ch2view.checked
            }
            LineSeries {
                id: linech3
                name: 'ch3'
                color: 'yellow'
                useOpenGL: true
                axisX: axisXch
                axisY: axisYch
                visible: ch3view.checked
            }
            LineSeries {
                id: linech4
                name: 'ch4'
                color: 'cyan'
                useOpenGL: true
                axisX: axisXch
                axisY: axisYch
                visible: ch4view.checked
            }
            LineSeries {
                id: linech5
                name: 'ch5'
                color: 'fuchsia'
                useOpenGL: true
                axisX: axisXch
                axisY: axisYch
                visible: ch5view.checked
            }
            LineSeries {
                id: linech6
                name: 'ch6'
                color: 'orange'
                useOpenGL: true
                axisX: axisXch
                axisY: axisYch
                visible: ch6view.checked
            }
            LineSeries {
                id: linech7
                name: 'ch7'
                color: 'lightgrey'
                useOpenGL: true
                axisX: axisXch
                axisY: axisYch
                visible: ch7view.checked
            }

            Rectangle {
                id: zoomarea
                color: 'transparent'
                border.color: 'red'
                border.width: 1
                visible: false
            }

            Text {
                id: coordinatestext
                width: 10
                height: 5
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 20
                color: 'white'
                text: 'x:  y: '
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                acceptedButtons: { Qt.RightButton | Qt.LeftButton }
                property var xstart
                property var ystart
                hoverEnabled: true

                onPressAndHold: {
                    if (mouse.button & Qt.RightButton){
                        xstart = mouseX
                        ystart = mouseY
                    }
                }

                onPositionChanged: {
                    var p = Qt.point(mouseX, mouseY)
                    var cp = chartviewchs.mapToValue(p, linech0)
                    var valuex = Math.round(cp.x * 1000) / 1000
                    var valuey = Math.round(cp.y * 1000) / 1000
                    coordinatestext.text = 'x: ' + valuex + '  y: ' + valuey
                    if (xstart) {
                        zoomarea.visible = true
                        zoomarea.x = xstart
                        zoomarea.y = ystart
                        zoomarea.width = Math.abs(mouseX - xstart)
                        zoomarea.height = Math.abs(mouseY - ystart)
                    }

                }

                onReleased: {
                    var xfinish = mouseX
                    var yfinish = mouseY
                    if (xstart) {
                        var r = Qt.rect(xstart, ystart, Math.abs(xfinish - xstart), Math.abs(yfinish - ystart))
                        chartviewchs.zoomIn(r)
                        xstart = false
                        zoomarea.visible = false
                    }
                }

                onClicked: {
                    if (mouse.button & Qt.RightButton) {
                        chartviewchs.zoomReset()
                    }
                }
            }
        }

        Item {
            id: chartviewpowersholder
            y: plot2combobox.currentIndex == 0 ? parent.height : parent.height / 2
            height: parent.height / 2
            anchors.right: rectangle.left
            anchors.left: parent.left

            ChartView {
                id: chartviewtemp
                anchors.fill: parent
                antialiasing: false
                theme: ChartView.ChartThemeDark
                visible: plot2combobox.currentIndex == 1

                ValueAxis {
                    id: axisXtemp
                    min: 0
                    max: 60
                    titleText: 'Time (s)'
                }

                ValueAxis {
                    id: axisYtemp
                    min: 22
                    max: 30
                    titleText:"Temp. (C)"
                }

                LineSeries {
                    id: linetemp
                    name: 'Temp.'
                    color: 'red'
                    axisX: axisXtemp
                    axisY: axisYtemp
                    useOpenGL: true
                }
            }

            ChartView {
                id: chartview5V
                anchors.fill: parent
                antialiasing: false
                theme: ChartView.ChartThemeDark
                visible: plot2combobox.currentIndex == 2

                ValueAxis {
                    id: axisX5V
                    min: 0
                    max: 60
                    titleText: 'Time (s)'
                }

                ValueAxis {
                    id: axisY5V
                    min: 4.5
                    max: 5.5
                    titleText:"Voltage (V)"
                }

                LineSeries {
                    id: line5V
                    name: '5V'
                    color: 'blue'
                    axisX: axisX5V
                    axisY: axisY5V
                    useOpenGL: true
                }
            }

            ChartView {
                id: chartviewPS
                anchors.fill: parent
                antialiasing: false
                theme: ChartView.ChartThemeDark
                visible: plot2combobox.currentIndex == 3

                ValueAxis {
                    id: axisXPS
                    min: 0
                    max: 60
                    titleText: 'Time (s)'
                }

                ValueAxis {
                    id: axisYPS
                    min: 50
                    max: 80
                    titleText:"Voltage (V)"
                }

                LineSeries {
                    id: linePS
                    name: 'PS'
                    color: 'lightgreen'
                    axisX: axisXPS
                    axisY: axisYPS
                    useOpenGL: true
                }
            }

            ChartView {
                id: chartviewminus12V
                anchors.fill: parent
                antialiasing: false
                theme: ChartView.ChartThemeDark
                visible: plot2combobox.currentIndex == 4

                ValueAxis {
                    id: axisXminus12V
                    min: 0
                    max: 60
                    titleText: 'Time (s)'
                }

                ValueAxis {
                    id: axisYminus12V
                    min: -14
                    max: -12
                    titleText:"Voltage (V)"
                }

                LineSeries {
                    id: lineminus12V
                    name: '-12V'
                    color: 'yellow'
                    axisX: axisXminus12V
                    axisY: axisYminus12V
                    useOpenGL: true
                }
            }

            ChartView {
                id: chartviewvref
                anchors.fill: parent
                antialiasing: false
                theme: ChartView.ChartThemeDark
                visible: plot2combobox.currentIndex == 5

                ValueAxis {
                    id: axisXvref
                    min: 0
                    max: 60
                    titleText: 'Time (s)'
                }

                ValueAxis {
                    id: axisYvref
                    min: 0
                    max: 1
                    titleText:"Voltage (V)"
                }

                LineSeries {
                    id: linevref
                    name: 'Vref'
                    color: 'orange'
                    axisX: axisXvref
                    axisY: axisYvref
                    useOpenGL: true
                }
            }
        }
    }

    Connections {
        target: listain
        property real time
        property real temp
        property real ch0v
        property real ch1v
        property real ch2v
        property real ch3v
        property real ch4v
        property real ch5v
        property real ch6v
        property real ch7v
        property real ps
        property real v5
        property real minus12V
        property real vref



        onSignaldatain: {
            time = lista[0]
            if (time > 60) {
                axisXtemp.max = time
                //axisXtemp.min = time - 60
                axisXch.max = time
                //axisXch.min = time - 60
                axisX5V.max = time
                //axisX5V.min = time - 60
                axisXPS.max = time
                //axisXPS.min = time - 60
                axisXminus12V.max = time
                //axisXminus12V.min = time - 60
                axisXvref.max = time
                //axisXvref.min = time - 60
            }

            temp = lista[1]
            if (temp > axisYtemp.max) {axisYtemp.max = temp * 1.05}
            if (temp < axisYtemp.min) {axisYtemp.min = temp * 0.95}
            ch0v = -lista[2]  * 20.48 / 65535 + 10.24
            if (ch0v > axisYch.max) {axisYch.max = ch0v * 1.05}
            if (ch0v < axisYch.min) {axisYch.min = ch0v * 1.95}
            ch1v = -lista[3]  * 20.48 / 65535 + 10.24
            if (ch1v > axisYch.max) {axisYch.max = ch1v * 1.05}
            if (ch1v < axisYch.min) {axisYch.min = ch1v * 1.95}
            ch2v = -lista[4]  * 20.48 / 65535 + 10.24
            if (ch2v > axisYch.max) {axisYch.max = ch2v * 1.05}
            if (ch2v < axisYch.min) {axisYch.min = ch2v * 1.95}
            ch3v = -lista[5]  * 20.48 / 65535 + 10.24
            if (ch3v > axisYch.max) {axisYch.max = ch3v * 1.05}
            if (ch3v < axisYch.min) {axisYch.min = ch3v * 1.95}
            ch4v = -lista[6]  * 20.48 / 65535 + 10.24
            if (ch4v > axisYch.max) {axisYch.max = ch4v * 1.05}
            if (ch4v < axisYch.min) {axisYch.min = ch4v * 1.95}
            ch5v = -lista[7]  * 20.48 / 65535 + 10.24
            if (ch5v > axisYch.max) {axisYch.max = ch5v * 1.05}
            if (ch5v < axisYch.min) {axisYch.min = ch5v * 1.95}
            ch6v = -lista[8]  * 20.48 / 65535 + 10.24
            if (ch6v > axisYch.max) {axisYch.max = ch6v * 1.05}
            if (ch6v < axisYch.min) {axisYch.min = ch6v * 1.95}
            ch7v = -lista[9]  * 20.48 / 65535 + 10.24
            if (ch7v > axisYch.max) {axisYch.max = ch7v * 1.05}
            if (ch7v < axisYch.min) {axisYch.min = ch7v * 1.95}
            v5 = lista[10] * 0.1875 / 1000
            if (v5 > axisY5V.max) {axisY5V.max = v5 * 1.05}
            if (v5 < axisY5V.min) {axisY5V.min = v5 * 0.95}
            ps = lista[11] * 0.1875 * 16.341 / 1000
            if (ps > axisYPS.max) {axisYPS.max = ps * 1.05}
            if (ps < axisYPS.min) {axisYPS.min = ps * 0.95}
            minus12V = lista[12] * 0.1875 * -2.6470 / 1000
            if (minus12V > axisYminus12V.max) {axisYminus12V.max = minus12V * 1.05}
            if (minus12V < axisYminus12V.min) {axisYminus12V = minus12V * 0.95}
            vref = lista[13] * 0.0625 / 1000
            if (vref > axisYvref.max) {axisYvref.max = vref * 1.05}
            if (vref < axisYvref.min) {axisYvref.min = vref * 0.95}
            linetemp.append(time, temp)
            linech0.append(time, ch0v)
            linech1.append(time, ch1v)
            linech2.append(time, ch2v)
            linech3.append(time, ch3v)
            linech4.append(time, ch4v)
            linech5.append(time, ch5v)
            linech6.append(time, ch6v)
            linech7.append(time, ch7v)
            line5V.append(time, v5)
            linePS.append(time, ps)
            lineminus12V.append(time, minus12V)
            linevref.append(time, vref)

        }

    }

}

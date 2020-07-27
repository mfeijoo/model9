import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Window 2.10
import QtCharts 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQuick.VirtualKeyboard 2.1


ApplicationWindow {
    id: mainwindow
    objectName: 'mainapplication'
    width: Screen.width
    height: Screen.height
    title: " Blue Physics v. 9.0.1"
    visible: true

    Material.theme: Material.Dark
    Material.accent: Material.LightBlue

    property var lqmlchs: [qmlch0, qmlch1, qmlch2, qmlch3, qmlch4, qmlch5, qmlch6, qmlch7]

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
            source: "iconspd/logo-bluephysics-transparent.svg"
            fillMode: Image.PreserveAspectFit
        }

        ToolButton {
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

            onClicked: {
                mainmenu.visible = false
                metadataview.visible = true
            }

        }

        ToolButton {
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

            onClicked: {
                measureview.visible = true
                mainmenu.visible = false
            }
        }

        ToolButton {
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

            onClicked: Qt.quit()
        }
    }

    Item {
        id: metadataview
        anchors.fill: parent
        visible: false

        InputPanel {
            id: inputpanel
            y: Qt.inputMethod.visible ? parent.height - inputpanel.height : parent.height
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Rectangle {
            id: metadatatoolbar
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


            ToolButton {
                id: metadatabacktomainmenubutton
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

                onClicked: {
                    metadataview.visible = false
                    mainmenu.visible = true
                }
            }
        }

        GroupBox {
            id: savefilegroupbox
            title: 'File. Save as:'
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 12
            width: 300
            height: 100
            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left

                TextInput {
                    id: filename
                    objectName: 'filename'
                    width: 200
                    text: 'default'
                    color: 'lightgrey'

                }
                Text {text: '.csv'; color: 'lightgrey'}
           }
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

            ToolButton {
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
                height: 220

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
                    text: regulatebutton.checked ? 'Regulating' : 'Regulate'
                    hoverEnabled: true
                    checkable: true
                    enabled: startbutton.checked ? false : true

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

                ToolButton {
                    id: subtractdc
                    objectName: 'subtractdcb'
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    hoverEnabled: true
                    text: subtractdc.checked ? 'Subtracting' : 'Subtract'
                    height: 50
                    checkable: true
                    enabled: (startbutton.checked | regulatebutton.checked) ? false : true

                }

                ProgressBar {
                    id: sdcprogressbar
                    objectName: 'sdcprogressbar'
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: subtractdc.bottom
                    anchors.topMargin: 6
                    from: 0
                    to: 8
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
                enabled: (subtractdc.checked | regulatebutton.checked) ? false : true


                onClicked: {
                    axisXtemp.min = 0
                    axisXtemp.max = 60
                    axisYtemp.first = true
                    linetemp.clear()
                    axisXPS.min = 0
                    axisXPS.max = 60
                    axisYPS.first = true
                    linePS.clear()
                    axisX5V.min = 0
                    axisX5V.max = 60
                    axisY5V.first = true
                    line5V.clear()
                    axisXvref.min = 0
                    axisXvref.max = 60
                    axisYvref.first = true
                    linevref.clear()
                    axisXminus12V.min = 0
                    axisXminus12V.max = 60
                    axisYminus12V.first = true
                    lineminus12V.clear()
                    chartviewchs.removeAllSeries()
                    axisXch.min = 0
                    axisXch.max = 60
                    axisYch.first = true
                    var colors = ['red', 'lightblue', 'lightgreen', 'yellow', 'cyan', 'fuchsia', 'orange', 'lightgrey']

                    for (var i = 0; i < 8; i++){
                        var serienow = chartviewchs.createSeries(ChartView.SeriesTypeLine, 'ch' + i, axisXch, axisYch)
                        serienow.color = colors[i]
                        serienow.useOpenGL = true
                    }


                    ma.starttimes = []
                    ma.finishtimes = []
                    stopbutton.enabled = true
                    for (var j = 0; j < 8; j++){listmodelfullintegrals.setProperty(j, 'fullintegral', 0)}
                    intbeamsitem.visible = false
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

                    Repeater {
                        model: 8
                        ToolButton {
                            text: 'ch' + index
                            checkable: true
                            hoverEnabled: true
                            checked: true

                            onClicked: {
                                chartviewchs.series('ch' + index).visible = checked
                                legendlist.itemAt(index).visible = checked
                                intlist.itemAt(index).visible = checked
                            }
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
            legend.visible: false

            Item {
                id: mylegend
                anchors.left: coordinatestext.right
                anchors.leftMargin: 400
                //anchors.horizontalCenter: mainwindow.horizontalCenter
                //anchors.top: parent.top
                anchors.topMargin: 10
                Row {
                    spacing: 5
                    Repeater {
                        id: legendlist
                        model: ListModel {
                            id: listmodelfullintegrals
                            ListElement {
                                mycolor: 'red'
                                fullintegral: 0
                                }
                            ListElement {
                                mycolor: 'lightblue'
                                fullintegral: 0
                                }
                            ListElement {
                                mycolor: 'lightgreen'
                                fullintegral: 0
                                }
                            ListElement {
                                mycolor: 'yellow'
                                fullintegral: 0
                                }
                            ListElement {
                                mycolor: 'cyan'
                                fullintegral: 0
                                }
                            ListElement {
                                mycolor: 'fuchsia'
                                fullintegral: 0
                                }
                            ListElement {
                                mycolor: 'orange'
                                fullintegral: 0
                                }
                            ListElement {
                                mycolor: 'lightgrey'
                                fullintegral: 0
                                }
                        }


                        Item {
                            width: 100
                            height: 20
                            visible: true
                            Row {
                                spacing: 3
                                Rectangle {
                                   width: 10
                                    height: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: mycolor
                                    border.width: 1
                                }

                                Text {
                                    text: fullintegral > 0 ? 'ch' + index + ' ' + fullintegral : 'ch' + index
                                    color: 'lightgrey'
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }


                    }
                }
            }

            ValueAxis {
                id: axisXch
                min: 0
                max: 60
                titleText: 'Time (s)'
            }

            ValueAxis {
                id: axisYch
                property bool first: true
                titleText: 'Voltage (V)'
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
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 20
                color: 'white'
                text: 'x:  y: '
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                acceptedButtons: { Qt.RightButton | Qt.LeftButton }
                property real xstart
                property real ystart
                property var starttimes: []
                property var finishtimes: []
                property int lineserieshovered: -1
                hoverEnabled: true

                onPressAndHold: {
                    if (mouse.button & Qt.RightButton){
                        xstart = mouseX
                        ystart = mouseY
                    }
                }

                Item {
                    id: intbeamsitem
                    visible: false
                    Column {
                        spacing: 3
                        Repeater {
                            id: intlist
                            model: ListModel {
                                id: integralsmodel
                                ListElement {
                                    mycolor: 'red'
                                    intvalue: 0
                                }
                                ListElement {
                                    mycolor: 'lightblue'
                                    intvalue: 0
                                }
                                ListElement {
                                    mycolor: 'lightgreen'
                                    intvalue: 0
                                }
                                ListElement {
                                    mycolor: 'yellow'
                                    intvalue: 0
                                }
                                ListElement {
                                    mycolor: 'cyan'
                                    intvalue: 0
                                }
                                ListElement {
                                    mycolor: 'fuchsia'
                                    intvalue: 0
                                }
                                ListElement {
                                    mycolor: 'orange'
                                    intvalue: 0
                                }
                                ListElement {
                                    mycolor: 'lightgrey'
                                    intvalue: 0
                                }
                            }
                            Item {
                                width: 40
                                height: 20
                                visible: true
                                Row {
                                    spacing: 3
                                    Rectangle {
                                       width: 10
                                        height: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: mycolor
                                        border.width: 1
                                    }

                                    Text {
                                        text: 'ch' + index + ': ' + intvalue
                                        color: 'lightgrey'
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }

                onPositionChanged: {
                    var p = Qt.point(mouseX, mouseY)
                    var cp = chartviewchs.mapToValue(p, chartviewchs.series('ch0'))
                    var valuex = cp.x.toFixed(2)
                    var valuey = cp.y.toFixed(2)

                    if (starttimes.length > 0 & finishtimes.length == starttimes.length){
                        for (var i = 0; i < starttimes.length; i++) {

                            if ( valuex > starttimes[i] & valuex < finishtimes[i]){
                                intbeamsitem.visible = true
                                intbeamsitem.x = mouseX
                                intbeamsitem.y = mouseY
                                for (var j = 0; j < 8; j++){
                                   //console.log('ch' + j + ' object name at ' + i + ' is ' + typeof (lqmlchs[j].listaint[i]))
                                   integralsmodel.setProperty(j, 'intvalue', lqmlchs[j].listaint[i].toFixed(2))
                                }
                            }
                        }

                    }
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
                    property bool first: true
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
                    property bool first: true
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
                    property bool first: true
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
                    property bool first: true
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
                    property bool first: true
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

            var temp = lista[1]
            if (axisYtemp.first == true) {
                axisYtemp.min = temp - 0.005
                axisYtemp.max = temp + 0.005
                axisYtemp.first = false

            }
            else {
                if (temp > axisYtemp.max) {axisYtemp.max = temp + 0.005}
                if (temp < axisYtemp.min) {axisYtemp.min = temp - 0.005}
            }


            var ch0v = -lista[2]  * 20.48 / 65535 + 10.24
            if (axisYch.first == true) {
                axisYch.min = ch0v - 0.005
                axisYch.max = ch0v + 0.005
            }
            else {
                if (ch0v > axisYch.max) {axisYch.max = ch0v + 0.005}
                if (ch0v < axisYch.min) {axisYch.min = ch0v - 0.005}
            }

            var ch1v = -lista[3]  * 20.48 / 65535 + 10.24
            if (axisYch.first == true) {
                axisYch.min = ch1v - 0.005
                axisYch.max = ch1v + 0.005
            }
            else {
                if (ch1v > axisYch.max) {axisYch.max = ch1v + 0.005}
                if (ch1v < axisYch.min) {axisYch.min = ch1v - 0.005}
            }

            var ch2v = -lista[4]  * 20.48 / 65535 + 10.24
            if (axisYch.first == true) {
                axisYch.min = ch2v - 0.005
                axisYch.max = ch2v + 0.005
            }
            else {
                if (ch2v > axisYch.max) {axisYch.max = ch2v + 0.005}
                if (ch2v < axisYch.min) {axisYch.min = ch2v - 0.005}
            }

            var ch3v = -lista[5]  * 20.48 / 65535 + 10.24
            if (axisYch.first == true) {
                axisYch.min = ch3v - 0.005
                axisYch.max = ch3v + 0.005
            }
            else {
                if (ch3v > axisYch.max) {axisYch.max = ch3v + 0.005}
                if (ch3v < axisYch.min) {axisYch.min = ch3v - 0.005}
            }

            var ch4v = -lista[6]  * 20.48 / 65535 + 10.24
            if (axisYch.first == true) {
                axisYch.min = ch4v - 0.005
                axisYch.max = ch4v + 0.005
            }
            else {
                if (ch4v > axisYch.max) {axisYch.max = ch4v + 0.005}
                if (ch4v < axisYch.min) {axisYch.min = ch4v - 0.005}
            }

            var ch5v = -lista[7]  * 20.48 / 65535 + 10.24
            if (axisYch.first == true) {
                axisYch.min = ch5v - 0.005
                axisYch.max = ch5v + 0.005
            }
            else {
                if (ch5v > axisYch.max) {axisYch.max = ch5v + 0.005}
                if (ch5v < axisYch.min) {axisYch.min = ch5v - 0.005}
            }

            var ch6v = -lista[8]  * 20.48 / 65535 + 10.24
            if (axisYch.first == true) {
                axisYch.min = ch6v - 0.005
                axisYch.max = ch6v + 0.005
            }
            else {
                if (ch6v > axisYch.max) {axisYch.max = ch6v + 0.005}
                if (ch6v < axisYch.min) {axisYch.min = ch6v - 0.005}
            }


            var ch7v = -lista[9]  * 20.48 / 65535 + 10.24
            if (axisYch.first == true) {
                axisYch.min = ch7v - 0.005
                axisYch.max = ch7v + 0.005
                axisYch.first = false
            }
            else {
                if (ch7v > axisYch.max) {axisYch.max = ch7v + 0.005}
                if (ch7v < axisYch.min) {axisYch.min = ch7v - 0.005}
            }


            var v5 = lista[10] * 0.1875 / 1000
            if (axisY5V.first == true) {
                axisY5V.min = v5 - 0.0005
                axisY5V.max = v5 + 0.0005
                axisY5V.first = false

            }
            else {
                if (v5 > axisY5V.max) {axisY5V.max = v5 + 0.0005}
                if (v5 < axisY5V.min) {axisY5V.min = v5 - 0.0005}
            }


            var ps = lista[11] * 0.1875 * 16.341 / 1000
            if (axisYPS.first == true) {
                axisYPS.min = ps - 0.005
                axisYPS.max = ps + 0.005
                axisYPS.first = false

            }
            else {
                if (ps > axisYPS.max) {axisYPS.max = ps + 0.005}
                if (ps < axisYPS.min) {axisYPS.min = ps - 0.005}
            }


            var minus12V = lista[12] * 0.1875 * -2.6470 / 1000
            if (axisYminus12V.first == true) {
                axisYminus12V.min = minus12V - 0.0005
                axisYminus12V.max = minus12V + 0.0005
                axisYminus12V.first = false

            }
            else {
                if (minus12V > axisYminus12V.max) {axisYminus12V.max = minus12V + 0.0005}
                if (minus12V < axisYminus12V.min) {axisYminus12V.min = minus12V - 0.0005}
            }

            var vref = lista[13] * 0.0625 / 1000
            if (axisYvref.first == true) {
                axisYvref.min = vref - 0.00005
                axisYvref.max = vref + 0.00005
                axisYvref.first = false

            }
            else {
                if (vref > axisYvref.max) {axisYvref.max = vref + 0.00005}
                if (vref < axisYvref.min) {axisYvref.min = vref - 0.00005}
            }


            linetemp.append(time, temp)
            chartviewchs.series('ch0').append(time, ch0v)
            chartviewchs.series('ch1').append(time, ch1v)
            chartviewchs.series('ch2').append(time, ch2v)
            chartviewchs.series('ch3').append(time, ch3v)
            chartviewchs.series('ch4').append(time, ch4v)
            chartviewchs.series('ch5').append(time, ch5v)
            chartviewchs.series('ch6').append(time, ch6v)
            chartviewchs.series('ch7').append(time, ch7v)
            line5V.append(time, v5)
            linePS.append(time, ps)
            lineminus12V.append(time, minus12V)
            linevref.append(time, vref)

        }

    }

    Connections {
        target: limitslines
        onSignallimitsin: {
            console.log('start times 0: ' + starttimes[0])
            console.log('finish times 0: ' + finishtimes[0])
            //var lqmlchs = [qmlch0, qmlch1, qmlch2, qmlch3, qmlch4, qmlch5, qmlch6, qmlch7]
            for (var m = 0; m < 8; m++){
                for (var k=0; k < chartviewchs.series('ch'+m).count; k++){
                    chartviewchs.series('ch'+m).replace(chartviewchs.series('ch'+m).at(k).x, chartviewchs.series('ch'+m).at(k).y, chartviewchs.series('ch'+m).at(k).x, chartviewchs.series('ch' + m).at(k).y - lqmlchs[m].zero)
                }
            }

            for (var i = 0; i < starttimes.length; i++){
                var starlimit = chartviewchs.createSeries(ChartView.SeriesTypeLine, 'start' + i, axisXch, axisYch)
                starlimit.color = 'lightgreen'
                starlimit.style = Qt.DashLine
                starlimit.append (starttimes[i] - 2, axisYch.min)
                starlimit.append (starttimes[i] - 2 , axisYch.max)
            }

            for (var j = 0; j < finishtimes.length; j++){
                var finishlimit = chartviewchs.createSeries(ChartView.SeriesTypeLine, 'finish' + j, axisXch, axisYch)
                finishlimit.color = 'lightsalmon'
                finishlimit.style = Qt.DashLine
                finishlimit.append (finishtimes[j] + 2, axisYch.min)
                finishlimit.append (finishtimes[j] + 2 , axisYch.max)
            }

            axisYch.min = 0
            ma.starttimes = starttimes
            ma.finishtimes = finishtimes
            for (var x = 0; x < 8; x++){
                listmodelfullintegrals.setProperty(x, 'fullintegral', lqmlchs[x].integral.toFixed(2))
            }

        }
    }

}

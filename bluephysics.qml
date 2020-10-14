import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Window 2.10
import QtCharts 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQuick.VirtualKeyboard 2.1
import QtQuick.Dialogs 1.3


ApplicationWindow {
    id: mainwindow
    objectName: 'mainapplication'
    width: Screen.width
    height: Screen.height
    title: "Blue Physics v9.2 file: " + filename.text + '.csv'
    visible: true

    Material.theme: Material.Dark
    Material.accent: Material.LightBlue

    property var lqmlchs: [qmlch0, qmlch1, qmlch2, qmlch3, qmlch4, qmlch5, qmlch6, qmlch7]
    property var lqmlanalyzechs: [qmlchanalyze0, qmlchanalyze1, qmlchanalyze2, qmlchanalyze3, qmlchanalyze4, qmlchanalyze5, qmlchanalyze6, qmlchanalyze7]
    property var colors: ['red', 'lightblue', 'lightgreen', 'yellow', 'cyan', 'fuchsia', 'orange', 'lightgrey']
    property var pair0chsen
    property var pair0chche
    property var pair1chsen
    property var pair1chche
    property var pair2chsen
    property var pair2chche
    property var pair3chsen
    property var pair3chche
    property var pair0chargedose
    property var pair1chargedose
    property var pair2chargedose
    property var pair3chargedose
    property var pair0dose
    property var pair1dose
    property var pair2dose
    property var pair3dose
    property var analyzepair0chsen
    property var analyzepair0chche
    property var analyzepair1chsen
    property var analyzepair1chche
    property var analyzepair2chsen
    property var analyzepair2chche
    property var analyzepair3chsen
    property var analyzepair3chche
    property var analyzepair0chargedose
    property var analyzepair1chargedose
    property var analyzepair2chargedose
    property var analyzepair3chargedose
    property var analyzepair0dose
    property var analyzepair1dose
    property var analyzepair2dose
    property var analyzepair3dose

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

        Row {
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 40


            ToolButton {
                id: measurebutton
                width: 125
                height: 125
                hoverEnabled: true
                text: "Measure"
                font.pointSize: 12
                icon.source: "iconspd/measure.png"
                icon.height: 100
                display: AbstractButton.TextUnderIcon
                icon.width: 100
                icon.color: 'transparent'

                onClicked: {
                    measureview.visible = true
                    mainmenu.visible = false
                }
            }

            ToolButton {
                id: metadatabutton
                objectName: 'metadatabutton'
                width: 125
                height: 125
                hoverEnabled: true
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
                id: analyzebutton
                width: 125
                height: 125
                hoverEnabled: true
                text: "Analyze"
                font.pointSize: 12
                icon.source: "iconspd/analyze.png"
                icon.height: 100
                display: AbstractButton.TextUnderIcon
                icon.width: 100
                icon.color: 'transparent'

                onClicked: {
                    analyzeview.visible = true
                    mainmenu.visible = false
                }
            }

            ToolButton {
                id: turnoffbutton
                width: 125
                height: 125
                text: "Turn Off"
                hoverEnabled: true
                icon.source: "iconspd/turnoff.png"
                icon.height: 100
                font.pointSize: 12
                display: AbstractButton.TextUnderIcon
                icon.width: 100
                icon.color: "#00000000"

                onClicked: Qt.quit()
            }
        }


    }

    Item {
        id: analyzeview
        visible: false
        anchors.fill: parent


        FileDialog {
            id: filedialog
            objectName: 'analyzefile'
            folder: "rawdata"
            visible: false
            nameFilters: ["*.csv"]
            title: "Chose a file to analyze"
            onRejected: visible = false
            onAccepted: {
                var path = filedialog.fileUrl.toString()
                mainwindow.title = "Blue Physics v9.2 analyzing " + path
                analyzechargebt.enabled = true
                analyzechargedosebt.enabled = true
                analyzedosebt.enabled = true
                analyzechartviewchs.removeAllSeries()
                for (var i = 0; i < 8; i++){
                    var serienow = analyzechartviewchs.createSeries(ChartView.SeriesTypeLine, 'ch' + i, analyzeaxisXch, analyzeaxisYch)
                    serienow.color = colors[i]
                    serienow.useOpenGL = true
                }

                for (var j = 0; j < 8; j++){
                    if (lqmlanalyzechs[j].name === pair0chsensor.currentText){
                        analyzepair0chsen = lqmlanalyzechs[j]
                    }
                    if (lqmlanalyzechs[j].name === pair0chcherenkov.currentText){
                        analyzepair0chche = lqmlanalyzechs[j]
                    }
                    if (lqmlanalyzechs[j].name === pair1chsensor.currentText){
                        analyzepair1chsen = lqmlanalyzechs[j]
                    }
                    if (lqmlanalyzechs[j].name === pair1chcherenkov.currentText){
                        analyzepair1chche = lqmlanalyzechs[j]
                    }
                    if (lqmlanalyzechs[j].name === pair2chsensor.currentText){
                        analyzepair2chsen = lqmlanalyzechs[j]
                    }
                    if (lqmlanalyzechs[j].name === pair2chcherenkov.currentText){
                        analyzepair2chche = lqmlanalyzechs[j]
                    }
                    if (lqmlanalyzechs[j].name === pair3chsensor.currentText){
                        analyzepair3chsen = lqmlanalyzechs[j]
                    }
                    if (lqmlanalyzechs[j].name === pair3chcherenkov.currentText){
                        analyzepair3chche = lqmlanalyzechs[j]
                    }
                }
            }
        }

        Rectangle {
            id: analyzerectangle
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
                id: analyzebacktomainmenubutton
                width: 125
                height: 100
                anchors.top: parent.top
                anchors.topMargin: 6
                hoverEnabled: true
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "iconspd/home.png"
                icon.height: 90
                font.pointSize: 12
                display: AbstractButton.IconOnly
                icon.width: 90
                icon.color: "#00000000"

                onClicked: {
                    analyzeview.visible = false
                    mainmenu.visible = true
                    mainwindow.title = "Blue Physics v9.2 file: " + filename.text + '.csv'
                }
            }

            Button {
                id: loadfilebutton
                width: 125
                height: 50
                anchors.top: analyzebacktomainmenubutton.bottom
                anchors.topMargin: 6
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Load File"
                onClicked: filedialog.visible = true
            }

            GroupBox {
                id: analyzegroupboxplot1
                title: 'Plot1'
                anchors.top: loadfilebutton.bottom
                anchors.topMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.left: parent.left
                height: 350

                ButtonGroup {
                    id: analyzeresultsgroup
                    exclusive: true
                }


                GridLayout {
                    rows: 6
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
                                analyzechartviewchs.series('ch' + index).visible = checked
                                analyzelegendlist.itemAt(index).visible = checked
                                analyzeintlist.itemAt(index).visible = checked
                            }
                        }

                    }
                    ToolButton {
                        id: analyzechargebt
                        text: 'Chr'
                        enabled: false
                        checkable: true
                        checked: true
                        ButtonGroup.group: analyzeresultsgroup
                        onClicked: {
                             for(var i = 0; i < 8; i++){
                             analyzelistmodelfullintegrals.setProperty(i, 'mytext', 'ch' + i + ' ' + Math.round(lqmlanalyzechs[i].integral * 100)/100)
                             }
                        }
                    }
                    ToolButton {
                        id: analyzechargedosebt
                        text: '~dose'
                        enabled: false
                        checkable: true
                        checked: false
                        ButtonGroup.group: analyzeresultsgroup
                        onClicked: {
                            analyzelistmodelfullintegrals.setProperty(0, 'mytext', 'S0 ' + Math.round((analyzepair0chsen.integral - analyzepair0chche.integral * acr0.realValue) *100)/100)
                            analyzelistmodelfullintegrals.setProperty(1, 'mytext', '')
                            analyzelistmodelfullintegrals.setProperty(2, 'mytext', 'S1 ' + Math.round((analyzepair1chsen.integral - analyzepair1chche.integral * acr1.realValue) *100)/100)
                            analyzelistmodelfullintegrals.setProperty(3, 'mytext', '')
                            analyzelistmodelfullintegrals.setProperty(4, 'mytext', 'S2 ' + Math.round((analyzepair2chsen.integral - analyzepair2chche.integral * acr2.realValue) *100)/100)
                            analyzelistmodelfullintegrals.setProperty(5, 'mytext', '')
                            analyzelistmodelfullintegrals.setProperty(6, 'mytext', 'S3 ' + Math.round((analyzepair3chsen.integral - analyzepair3chche.integral * acr3.realValue) *100)/100)
                            analyzelistmodelfullintegrals.setProperty(7, 'mytext', '')

                        }

                    }
                    ToolButton {
                        id: analyzedosebt
                        text: 'Dose'
                        enabled: false
                        checkable: true
                        checked: false
                        ButtonGroup.group: analyzeresultsgroup
                        onClicked:{
                            analyzelistmodelfullintegrals.setProperty(0, 'mytext', 'S0 ' + Math.round((analyzepair0chsen.integral - analyzepair0chche.integral * acr0.realValue) * calib0.realValue * 100)/100)
                            analyzelistmodelfullintegrals.setProperty(1, 'mytext', '')
                            analyzelistmodelfullintegrals.setProperty(2, 'mytext', 'S1 ' + Math.round((analyzepair1chsen.integral - analyzepair1chche.integral * acr1.realValue) * calib1.realValue * 100)/100)
                            analyzelistmodelfullintegrals.setProperty(3, 'mytext', '')
                            analyzelistmodelfullintegrals.setProperty(4, 'mytext', 'S2 ' + Math.round((analyzepair2chsen.integral - analyzepair2chche.integral * acr2.realValue) * calib2.realValue * 100)/100)
                            analyzelistmodelfullintegrals.setProperty(5, 'mytext', '')
                            analyzelistmodelfullintegrals.setProperty(6, 'mytext', 'S3 ' + Math.round((analyzepair3chsen.integral - analyzepair3chche.integral * acr3.realValue) * calib3.realValue * 100)/100)
                            analyzelistmodelfullintegrals.setProperty(7, 'mytext', '')
                        }

                    }
                }
            }


            GroupBox {
                id: analyzegroupboxplot2view
                title: 'Plot2'
                anchors.top: analyzegroupboxplot1.bottom
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 6
                height: 100

                ComboBox {
                    id: analyzeplot2combobox
                    anchors.fill: parent
                    model: ['None', 'Temp', '5V', 'PS', '-12V', 'Vref']
                }
            }
        }

        ChartView {
            id: analyzechartviewchs
            anchors.top: parent.top
            anchors.bottom: analyzechartviewpowersholder.top
            anchors.left: parent.left
            anchors.right: analyzerectangle.left
            antialiasing: false
            theme: ChartView.ChartThemeDark
            legend.visible: false

            ListModel {
               id: analyzelistmodelfullintegrals
               ListElement {
                   mycolor: 'red'
                   fullintegral: 0
                   chargedose: 0
                   dose: 0
                   mytext: 'ch0'
                }
                ListElement {
                    mycolor: 'lightblue'
                    fullintegral: 0
                    chargedose: 0
                    dose: 0
                    mytext: 'ch1'
                }
                ListElement {
                    mycolor: 'lightgreen'
                    fullintegral: 0
                    chargedose: 0
                    dose: 0
                    mytext: 'ch2'
                }
                ListElement {
                    mycolor: 'yellow'
                    fullintegral: 0
                    chargedose: 0
                    dose: 0
                    mytext: 'ch3'
                }
                ListElement {
                     mycolor: 'cyan'
                     fullintegral: 0
                     chargedose: 0
                     dose: 0
                     mytext: 'ch4'
                }
                ListElement {
                     mycolor: 'fuchsia'
                     fullintegral: 0
                     chargedose: 0
                     dose: 0
                     mytext: 'ch5'
                }
                ListElement {
                     mycolor: 'orange'
                     fullintegral: 0
                     chargedose: 0
                     dose: 0
                     mytext: 'ch6'
                }
                ListElement {
                     mycolor: 'lightgrey'
                     fullintegral: 0
                     chargedose: 0
                     dose: 0
                     mytext: 'ch7'
                }
              }

            ListModel {
               id: analyzeintegralsmodel
               ListElement {
                   mycolor: 'red'
                   intvalue: 0
                   mytext: 'ch0'
               }
               ListElement {
                   mycolor: 'lightblue'
                   intvalue: 0
                   mytext: 'ch1'
               }
               ListElement {
                    mycolor: 'lightgreen'
                    intvalue: 0
                    mytext: 'ch2'
               }
               ListElement {
                    mycolor: 'yellow'
                    intvalue: 0
                    mytext: 'ch3'
               }
               ListElement {
                    mycolor: 'cyan'
                    intvalue: 0
                    mytext: 'ch4'
               }
               ListElement {
                    mycolor: 'fuchsia'
                    intvalue: 0
                    mytext: 'ch5'
               }
               ListElement {
                    mycolor: 'orange'
                    intvalue: 0
                    mytext: 'ch6'
               }
               ListElement {
                    mycolor: 'lightgrey'
                    intvalue: 0
                    mytext: 'ch7'
               }
             }

            Item {
                id: analyzemylegend
                anchors.left: analyzecoordinatestext.right
                anchors.leftMargin: 400
                //anchors.horizontalCenter: mainwindow.horizontalCenter
                //anchors.top: parent.top
                anchors.topMargin: 10
                Row {
                    spacing: 5
                    Repeater {
                        id: analyzelegendlist
                        model: analyzelistmodelfullintegrals

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
                                    text: mytext
                                    color: 'lightgrey'
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    Text {
                        id: analyzeunitsfullintegrals
                        text: (analyzechargebt.checked | analyzechargedosebt.checked) ? '(nC)' : '(cGy)'
                        color: 'lightgrey'
                    }
                }
            }

            ValueAxis {
                id: analyzeaxisXch
                min: 0
                max: 60
                titleText: 'Time (s)'
            }

            ValueAxis {
                id: analyzeaxisYch
                property bool first: true
                min: 0
                max: 60
                //titleText: 'Voltage (V)'
                titleText: 'Currrent (nA)'
            }





            Rectangle {
                id: analyzezoomarea
                color: 'transparent'
                border.color: 'red'
                border.width: 1
                visible: false
            }

            Text {
                id: analyzecoordinatestext
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
                id: analyzema
                anchors.fill: parent
                acceptedButtons: { Qt.RightButton | Qt.LeftButton }
                property real analyzexstart
                property real analyzeystart
                property var analyzestarttimes: []
                property var analyzefinishtimes: []
                property int analyzelineserieshovered: -1
                hoverEnabled: true
                property bool activezoom: false

                onPressAndHold: {
                    if (mouse.button & Qt.RightButton){
                        analyzexstart = mouseX
                        analyzeystart = mouseY
                    }
                }

                Item {
                    id: analyzeintbeamsitem
                    visible: false
                    Column {
                        spacing: 3
                        Repeater {
                            id: analyzeintlist
                            model: analyzeintegralsmodel

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
                                        text: mytext
                                        color: 'lightgrey'
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        Text {
                            id: analyzeintegralsunits
                            text: (analyzechargebt.checked | analyzechargedosebt.checked) ? '(nC)' : '(cGy)'
                            color: 'lightgrey'

                        }
                    }
                }

                onPositionChanged: {
                    var analyzep = Qt.point(mouseX, mouseY)
                    var analyzecp = analyzechartviewchs.mapToValue(analyzep, analyzechartviewchs.series('ch0'))
                    var analyzevaluex = analyzecp.x.toFixed(2)
                    var analyzevaluey = analyzecp.y.toFixed(2)

                    if (analyzestarttimes.length > 0 & analyzefinishtimes.length === analyzestarttimes.length){
                        for (var i = 0; i < analyzestarttimes.length; i++) {

                            if ( analyzevaluex > analyzestarttimes[i] & analyzevaluex < analyzefinishtimes[i]){
                                analyzeintbeamsitem.visible = true
                                analyzeintbeamsitem.x = mouseX
                                analyzeintbeamsitem.y = mouseY
                                if (analyzechargebt.checked){
                                    for (var j = 0; j < 8; j++){
                                       //console.log('ch' + j + ' object name at ' + i + ' is ' + typeof (Math.round(lqmlchs[j].listaint[i]*100)/100))
                                      analyzeintegralsmodel.setProperty(j, 'mytext', 'ch' + j + ' ' + Math.round(lqmlanalyzechs[j].listaint[i] * 100)/100)
                                    }
                                }
                                if (analyzechargedosebt.checked){
                                    //console.log ('ch0 integrals: ' + analyzepair0chsen.listaint)
                                    analyzeintegralsmodel.setProperty(0, 'mytext', 'S0 ' + Math.round((analyzepair0chsen.listaint[i] - analyzepair0chche.listaint[i] * acr0.realValue)* 100)/100)
                                    analyzeintegralsmodel.setProperty(1, 'mytext', '')
                                    analyzeintegralsmodel.setProperty(2, 'mytext', 'S1 ' + Math.round((analyzepair1chsen.listaint[i] - analyzepair1chche.listaint[i] * acr1.realValue)* 100)/100)
                                    analyzeintegralsmodel.setProperty(3, 'mytext', '')
                                    analyzeintegralsmodel.setProperty(4, 'mytext', 'S2 ' + Math.round((analyzepair2chsen.listaint[i] - analyzepair2chche.listaint[i] * acr2.realValue)* 100)/100)
                                    analyzeintegralsmodel.setProperty(5, 'mytext', '')
                                    analyzeintegralsmodel.setProperty(6, 'mytext', 'S3 ' + Math.round((analyzepair3chsen.listaint[i] - analyzepair3chche.listaint[i] * acr3.realValue)* 100)/100)
                                    analyzeintegralsmodel.setProperty(7, 'mytext', '')
                                }
                                if (analyzedosebt.checked){
                                    analyzeintegralsmodel.setProperty(0, 'mytext', 'S0 ' + Math.round((analyzepair0chsen.listaint[i] - analyzepair0chche.listaint[i] * acr0.realValue) * calib0.realValue * 100)/100)
                                    analyzeintegralsmodel.setProperty(1, 'mytext', '')
                                    analyzeintegralsmodel.setProperty(2, 'mytext', 'S1 ' + Math.round((analyzepair1chsen.listaint[i] - analyzepair1chche.listaint[i] * acr1.realValue) * calib1.realValue * 100)/100)
                                    analyzeintegralsmodel.setProperty(3, 'mytext', '')
                                    analyzeintegralsmodel.setProperty(4, 'mytext', 'S2 ' + Math.round((analyzepair2chsen.listaint[i] - analyzepair2chche.listaint[i] * acr2.realValue) * calib2.realValue * 100)/100)
                                    analyzeintegralsmodel.setProperty(5, 'mytext', '')
                                    analyzeintegralsmodel.setProperty(6, 'mytext', 'S3 ' + Math.round((analyzepair3chsen.listaint[i] - analyzepair3chche.listaint[i] * acr3.realValue) * calib3.realValue * 100)/100)
                                    analyzeintegralsmodel.setProperty(7, 'mytext', '')
                                }


                            }
                        }

                    }
                    analyzecoordinatestext.text = 'x: ' + analyzevaluex + '  y: ' + analyzevaluey

                    if (analyzexstart) {
                        analyzezoomarea.visible = true
                        analyzezoomarea.x = analyzexstart
                        analyzezoomarea.y = analyzeystart
                        analyzezoomarea.width = Math.abs(mouseX - analyzexstart)
                        analyzezoomarea.height = Math.abs(mouseY - analyzeystart)
                    }

                }

                onReleased: {
                    var analyzexfinish = mouseX
                    var analyzeyfinish = mouseY
                    if (analyzexstart) {
                        var r = Qt.rect(analyzexstart, analyzeystart, Math.abs(analyzexfinish - analyzexstart), Math.abs(analyzeyfinish - analyzeystart))
                        analyzechartviewchs.zoomIn(r)
                        analyzema.activezoom = true
                        analyzexstart = false
                        analyzezoomarea.visible = false
                    }
                }

                onClicked: {
                    if (mouse.button & Qt.RightButton) {
                        analyzechartviewchs.zoomReset()
                        analyzema.activezoom = false
                    }
                }
            }
        }

        Item {
            id: analyzechartviewpowersholder
            y: analyzeplot2combobox.currentIndex == 0 ? parent.height : parent.height / 2
            height: parent.height / 2
            anchors.right: analyzerectangle.left
            anchors.left: parent.left

            ChartView {
                id: analyzechartviewtemp
                anchors.fill: parent
                antialiasing: false
                theme: ChartView.ChartThemeDark
                visible: analyzeplot2combobox.currentIndex == 1

                ValueAxis {
                    id: analyzeaxisXtemp
                    min: 0
                    max: 60
                    titleText: 'Time (s)'
                }

                ValueAxis {
                    id: analyzeaxisYtemp
                    property bool first: true
                    titleText:"Temp. (C)"
                    min: 22
                    max: 30
                }

                LineSeries {
                    id: analyzelinetemp
                    name: 'Temp.'
                    color: 'red'
                    axisX: analyzeaxisXtemp
                    axisY: analyzeaxisYtemp
                    useOpenGL: true
                }
            }

            ChartView {
                id: analyzechartview5V
                anchors.fill: parent
                antialiasing: false
                theme: ChartView.ChartThemeDark
                visible: analyzeplot2combobox.currentIndex == 2

                ValueAxis {
                    id: analyzeaxisX5V
                    min: 0
                    max: 60
                    titleText: 'Time (s)'
                }

                ValueAxis {
                    id: analyzeaxisY5V
                    property bool first: true
                    titleText:"Voltage (V)"
                    min: 4
                    max: 6
                }

                LineSeries {
                    id: analyzeline5V
                    name: '5V'
                    color: 'blue'
                    axisX: analyzeaxisX5V
                    axisY: analyzeaxisY5V
                    useOpenGL: true
                }
            }

            ChartView {
                id: analyzechartviewPS
                anchors.fill: parent
                antialiasing: false
                theme: ChartView.ChartThemeDark
                visible: analyzeplot2combobox.currentIndex == 3

                ValueAxis {
                    id: analyzeaxisXPS
                    min: 0
                    max: 60
                    titleText: 'Time (s)'
                }

                ValueAxis {
                    id: analyzeaxisYPS
                    property bool first: true
                    titleText:"Voltage (V)"
                    min: 56
                    max: 58
                }

                LineSeries {
                    id: analyzelinePS
                    name: 'PS'
                    color: 'lightgreen'
                    axisX: analyzeaxisXPS
                    axisY: analyzeaxisYPS
                    useOpenGL: true
                }
            }

            ChartView {
                id: analyzechartviewminus12V
                anchors.fill: parent
                antialiasing: false
                theme: ChartView.ChartThemeDark
                visible: analyzeplot2combobox.currentIndex == 4

                ValueAxis {
                    id: analyzeaxisXminus12V
                    min: 0
                    max: 60
                    titleText: 'Time (s)'
                }

                ValueAxis {
                    id: analyzeaxisYminus12V
                    property bool first: true
                    titleText:"Voltage (V)"
                    min: -12
                    max: -11
                }

                LineSeries {
                    id: analyzelineminus12V
                    name: '-12V'
                    color: 'yellow'
                    axisX: analyzeaxisXminus12V
                    axisY: analyzeaxisYminus12V
                    useOpenGL: true
                }
            }

            ChartView {
                id: analyzechartviewvref
                anchors.fill: parent
                antialiasing: false
                theme: ChartView.ChartThemeDark
                visible: analyzeplot2combobox.currentIndex == 5

                ValueAxis {
                    id: analyzeaxisXvref
                    min: 0
                    max: 60
                    titleText: 'Time (s)'
                }

                ValueAxis {
                    id: analyzeaxisYvref
                    property bool first: true
                    titleText:"Voltage (V)"
                    min: 0
                    max: 3
                }

                LineSeries {
                    id: analyzelinevref
                    name: 'Vref'
                    color: 'orange'
                    axisX: analyzeaxisXvref
                    axisY: analyzeaxisYvref
                    useOpenGL: true
                }
            }
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
            width: 125
            color: "transparent"
            z: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0


            Column {
                anchors.fill: parent
                spacing: 12

                ToolButton {
                    id: metadatabacktomainmenubutton
                    objectName: 'metadatabacktohome'
                    width: 125
                    height: 100
                    hoverEnabled: true
                    icon.source: "iconspd/home.png"
                    icon.height: 90
                    font.pointSize: 12
                    display: AbstractButton.IconOnly
                    icon.width: 90
                    icon.color: "#00000000"

                    onClicked: {
                        metadataview.visible = false
                        mainmenu.visible = true
                    }
                }

                GroupBox {
                    title: 'Emulator'
                    height: 260
                    width: 122

                    Column {
                        anchors.fill: parent
                        spacing: 6

                        Text {
                            text: 'socat port1'
                            color: 'lightgrey'
                        }
                        ComboBox {
                            id: socatport1
                            objectName: 'socatport1'
                            model: 6
                            width: parent.width
                        }
                        Text {
                            text: 'socat port2'
                            color: 'lightgrey'
                        }
                        ComboBox {
                            id: socatport2
                            objectName: 'socatport2'
                            model: 6
                            width: parent.width
                        }
                        Switch {
                            id: emulatorswitch
                            objectName: 'emulatorswitch'
                            width: parent.width
                            checked: false
                            text: checked ? qsTr("on") : qsTr("off")

                        }


                    }
                }

            }


        }

        GroupBox {
            id: savefilegroupbox
            title: 'Save as:'
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 12
            width: 300
            height: 100
            Row {
                anchors.verticalCenter: parent.verticalCenter

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

        GroupBox {
            id: controllergroupbox
            title: 'Controller Settings'
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: savefilegroupbox.bottom
            anchors.topMargin: 12
            width: 300
            height: 250


            GroupBox {
                id: integrationtimegroupbox
                title: 'Integration Time (ms)'
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 100


                 SpinBox {
                     id: integrationtimespinbox
                     objectName: 'integrationtimespinbox'
                     anchors.fill: parent
                     from: 0
                     to: 1000
                     value: 300
                     editable: true
                     onValueModified: sendtocontroller.enabled = true
                  }
                }

                Switch {
                     id: integrationpulseswitch
                     objectName: 'integrationpulseswitch'
                     anchors.left: parent.left
                     anchors.right: parent.right
                     anchors.top: integrationtimegroupbox.bottom
                     checked: true
                     text: checked ? qsTr("Integration Mode") : qsTr("Pulse Mode")
                     onCheckedChanged: sendtocontroller.enabled = true
                }

                Button {
                    id: sendtocontroller
                    objectName: 'sendtocontrollerbt'
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: integrationpulseswitch.bottom
                    text: qsTr("Send to Controller")
                    enabled: false
                }
        }

        GroupBox {
            id: sensorsinfo
            title: qsTr("Sensors Information")
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.left: savefilegroupbox.right
            anchors.leftMargin: 12
            anchors.bottom: controllergroupbox.bottom
            width: 800

            ScrollView {
                anchors.fill: parent
                clip: true

                GridLayout {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 8

                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("Pair")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }

                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("Ch. Sensor")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }

                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("Ch. Cherenk.")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }

                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("ACR")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }

                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("Calib. (cGy/nC)")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }

                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("X (cm)")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }

                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("Y (cm)")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }

                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("Z (cm)")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }

                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("0")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }
                    }
                    ComboBox {
                        id: pair0chsensor
                        objectName: 'pair0chsensor'
                        width: 120
                        height: 40
                        model: ['ch0', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6', 'ch7']
                    }
                    ComboBox {
                        id: pair0chcherenkov
                        objectName: 'pair0chcherenkov'
                        width: 120
                        height: 40
                        model: ['ch0', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6', 'ch7']
                        currentIndex: 1
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: acr0
                            objectName: 'acr0'
                            from: 0
                            value: 10000
                            to: 20000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 4
                            property real realValue: value / 10000

                            validator: DoubleValidator {
                                bottom: Math.min(acr0.from, acr0.to)
                                top: Math.max(acr0.from, acr0.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10000).toLocaleString(locale, 'f', acr0.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10000
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: calib0
                            objectName: 'calib0'
                            from: 0
                            value: 10000
                            to: 20000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 4
                            property real realValue: value / 10000

                            validator: DoubleValidator {
                                bottom: Math.min(calib0.from, calib0.to)
                                top: Math.max(calib0.from, calib0.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10000).toLocaleString(locale, 'f', calib0.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10000
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: x0
                            objectName: 'x0'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(x0.from, x0.to)
                                top: Math.max(x0.from, x0.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', x0.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: y0
                            objectName: 'y0'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(y0.from, y0.to)
                                top: Math.max(y0.from, y0.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', y0.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: z0
                            objectName: 'z0'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(z0.from, z0.to)
                                top: Math.max(z0.from, z0.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', z0.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("1")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }
                    }
                    ComboBox {
                        id: pair1chsensor
                        objectName: 'pair1chsensor'
                        width: 120
                        height: 40
                        model: ['ch0', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6', 'ch7']
                        currentIndex: 2
                    }
                    ComboBox {
                        id: pair1chcherenkov
                        objectName: 'pair1chcherenkov'
                        width: 120
                        height: 40
                        model: ['ch0', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6', 'ch7']
                        currentIndex: 3
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: acr1
                            objectName: 'acr1'
                            from: 0
                            value: 10000
                            to: 20000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 4
                            property real realValue: value / 10000

                            validator: DoubleValidator {
                                bottom: Math.min(acr1.from, acr1.to)
                                top: Math.max(acr1.from, acr1.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10000).toLocaleString(locale, 'f', acr1.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10000
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: calib1
                            objectName: 'calib1'
                            from: 0
                            value: 10000
                            to: 20000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 4
                            property real realValue: value / 10000

                            validator: DoubleValidator {
                                bottom: Math.min(calib1.from, calib1.to)
                                top: Math.max(calib1.from, calib1.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10000).toLocaleString(locale, 'f', calib1.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10000
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: x1
                            objectName: 'x1'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(x1.from, x1.to)
                                top: Math.max(x1.from, x1.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', x1.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: y1
                            objectName: 'y1'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(y1.from, y1.to)
                                top: Math.max(y1.from, y1.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', y1.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: z1
                            objectName: 'z1'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(z1.from, z1.to)
                                top: Math.max(z1.from, z1.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', z1.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("2")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }
                    }
                    ComboBox {
                        id: pair2chsensor
                        objectName: 'pair2chsensor'
                        width: 120
                        height: 40
                        model: ['ch0', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6', 'ch7']
                        currentIndex: 4
                    }
                    ComboBox {
                        id: pair2chcherenkov
                        objectName: 'pair2chcherenkov'
                        width: 120
                        height: 40
                        model: ['ch0', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6', 'ch7']
                        currentIndex: 5
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: acr2
                            objectName: 'acr2'
                            from: 0
                            value: 10000
                            to: 20000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 4
                            property real realValue: value / 10000

                            validator: DoubleValidator {
                                bottom: Math.min(acr2.from, acr2.to)
                                top: Math.max(acr2.from, acr2.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10000).toLocaleString(locale, 'f', acr2.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10000
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: calib2
                            objectName: 'calib2'
                            from: 0
                            value: 10000
                            to: 20000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 4
                            property real realValue: value / 10000

                            validator: DoubleValidator {
                                bottom: Math.min(calib2.from, calib2.to)
                                top: Math.max(calib2.from, calib2.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10000).toLocaleString(locale, 'f', calib2.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10000
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: x2
                            objectName: 'x2'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(x2.from, x2.to)
                                top: Math.max(x2.from, x2.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', x2.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: y2
                            objectName: 'y2'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(y2.from, y2.to)
                                top: Math.max(y2.from, y2.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', y2.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: z2
                            objectName: 'z2'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(z2.from, z2.to)
                                top: Math.max(z2.from, z2.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', z2.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        border.color: 'lightgrey'
                        Text {
                            text: qsTr("3")
                            color: 'lightgrey'
                            anchors.centerIn: parent
                        }
                    }
                    ComboBox {
                        id: pair3chsensor
                        objectName: 'pair3chsensor'
                        width: 120
                        height: 40
                        model: ['ch0', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6', 'ch7']
                        currentIndex: 6
                    }
                    ComboBox {
                        id: pair3chcherenkov
                        objectName: 'pair3chcherenkov'
                        width: 120
                        height: 40
                        model: ['ch0', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6', 'ch7']
                        currentIndex: 7
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: acr3
                            objectName: 'acr3'
                            from: 0
                            value: 10000
                            to: 20000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 4
                            property real realValue: value / 10000

                            validator: DoubleValidator {
                                bottom: Math.min(acr3.from, acr3.to)
                                top: Math.max(acr3.from, acr3.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10000).toLocaleString(locale, 'f', acr3.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10000
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: calib3
                            objectName: 'calib3'
                            from: 0
                            value: 10000
                            to: 20000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 4
                            property real realValue: value / 10000

                            validator: DoubleValidator {
                                bottom: Math.min(calib3.from, calib3.to)
                                top: Math.max(calib3.from, calib3.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10000).toLocaleString(locale, 'f', calib3.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10000
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: x3
                            objectName: 'x3'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(x3.from, x3.to)
                                top: Math.max(x3.from, x3.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', x3.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: y3
                            objectName: 'y3'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(y3.from, y3.to)
                                top: Math.max(y3.from, y3.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', y3.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                    Rectangle {
                        width: 120
                        height: 40
                        color: 'transparent'
                        SpinBox {
                            id: z3
                            objectName: 'z3'
                            from: -2000
                            value: 0
                            to: 2000
                            stepSize: 1
                            editable: true
                            anchors.fill: parent
                            font.pointSize: 10

                            property int decimals: 2
                            property real realValue: value / 100

                            validator: DoubleValidator {
                                bottom: Math.min(z3.from, z3.to)
                                top: Math.max(z3.from, z3.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, 'f', z3.decimals)
                            }
                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 100
                            }
                         }
                    }
                }
            }



        }

        GroupBox {
            id: comments
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.left: sensorsinfo.right
            anchors.leftMargin: 12
            anchors.right: metadatatoolbar.left
            anchors.rightMargin: 12
            height: 250
            title: 'Comments'
            TextEdit {
                id: commentstext
                objectName: 'commentstext'
                anchors.fill: parent
                color: 'lightgrey'
                wrapMode: TextEdit.WordWrap
            }
        }


        GroupBox {
            title: 'PS Coef.'
            anchors.top: comments.bottom
            anchors.topMargin: 12
            anchors.left: sensorsinfo.right
            anchors.leftMargin: 12
            anchors.bottom: sensorsinfo.bottom
            anchors.right: metadatatoolbar.left
            anchors.rightMargin: 12

            SpinBox{
                id: pscoef
                objectName: 'pscoef'
                from: 150000
                value: 162788
                to: 180000
                stepSize: 1
                editable: true
                anchors.fill: parent
                font.pointSize: 10

                property int decimals: 4
                property real realValue: value / 10000

                validator: DoubleValidator {
                    bottom: Math.min(pscoef.from, pscoef.to)
                    top: Math.max(pscoef.from, pscoef.to)
                }

                textFromValue: function(value, locale) {
                    return Number(value / 10000).toLocaleString(locale, 'f', pscoef.decimals)
                }
                valueFromText: function(text, locale) {
                    return Number.fromLocaleString(locale, text) * 10000
                }
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
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "iconspd/home.png"
                icon.height: 90
                font.pointSize: 12
                display: AbstractButton.IconOnly
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
                height: 170

                ToolButton {
                    id: psonoff
                    text: psonoff.checked ? 'on' : 'off'
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    checkable: true
                    checked: true
                    height: 25
                    hoverEnabled: true
                    enabled: regulatebutton.checked ? false : true

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
                    enabled: regulatebutton.checked ? false : true

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
                    height: 25
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
                    from: 56.4
                    to: psspinbox.realValue
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
                height: 90

                ToolButton {
                    id: subtractdc
                    objectName: 'subtractdcb'
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    hoverEnabled: true
                    text: subtractdc.checked ? 'Subtracting' : 'Subtract'
                    height: 25
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
                    for (var j = 0; j < 8; j++){listmodelfullintegrals.setProperty(j, 'mytext', 'ch' + j)}


                    ma.starttimes = []
                    ma.finishtimes = []
                    stopbutton.enabled = true
                    chargebt.checked = true
                    chargebt.enabled = false
                    chargedosebt.enabled = false
                    dosebt.enabled = false
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
                    //console.log('pair 0 ch sensor: ' + qmlch1.integral)

                    for (var i = 0; i < 8; i++){
                        if (lqmlchs[i].name === pair0chsensor.currentText){
                            pair0chsen = lqmlchs[i]
                        }
                        if (lqmlchs[i].name === pair0chcherenkov.currentText){
                            pair0chche = lqmlchs[i]
                        }
                        if (lqmlchs[i].name === pair1chsensor.currentText){
                            pair1chsen = lqmlchs[i]
                        }
                        if (lqmlchs[i].name === pair1chcherenkov.currentText){
                            pair1chche = lqmlchs[i]
                        }
                        if (lqmlchs[i].name === pair2chsensor.currentText){
                            pair2chsen = lqmlchs[i]
                        }
                        if (lqmlchs[i].name === pair2chcherenkov.currentText){
                            pair2chche = lqmlchs[i]
                        }
                        if (lqmlchs[i].name === pair3chsensor.currentText){
                            pair3chsen = lqmlchs[i]
                        }
                        if (lqmlchs[i].name === pair3chcherenkov.currentText){
                            pair3chche = lqmlchs[i]
                        }
                    }

                    chargebt.enabled = true
                    chargedosebt.enabled = true
                    dosebt.enabled = true
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
                height: 350

                ButtonGroup {
                    id: resultsgroup
                    exclusive: true
                }


                GridLayout {
                    rows: 6
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
                    ToolButton {
                        id: chargebt
                        text: 'Chr'
                        enabled: false
                        checkable: true
                        checked: true
                        ButtonGroup.group: resultsgroup
                        onClicked: {
                            for(var i = 0; i < 8; i++){
                                listmodelfullintegrals.setProperty(i, 'mytext', 'ch' + i + ' ' + Math.round(lqmlchs[i].integral * 100)/100)
                            }
                        }
                    }
                    ToolButton {
                        id: chargedosebt
                        text: '~dose'
                        enabled: false
                        checkable: true
                        checked: false
                        ButtonGroup.group: resultsgroup
                        onClicked: {
                            listmodelfullintegrals.setProperty(0, 'mytext', 'S0 ' + Math.round((pair0chsen.integral - pair0chche.integral * acr0.realValue) *100)/100)
                            listmodelfullintegrals.setProperty(1, 'mytext', '')
                            listmodelfullintegrals.setProperty(2, 'mytext', 'S1 ' + Math.round((pair1chsen.integral - pair1chche.integral * acr1.realValue) *100)/100)
                            listmodelfullintegrals.setProperty(3, 'mytext', '')
                            listmodelfullintegrals.setProperty(4, 'mytext', 'S2 ' + Math.round((pair2chsen.integral - pair2chche.integral * acr2.realValue) *100)/100)
                            listmodelfullintegrals.setProperty(5, 'mytext', '')
                            listmodelfullintegrals.setProperty(6, 'mytext', 'S3 ' + Math.round((pair3chsen.integral - pair3chche.integral * acr3.realValue) *100)/100)
                            listmodelfullintegrals.setProperty(7, 'mytext', '')
                        }

                    }
                    ToolButton {
                        id: dosebt
                        text: 'Dose'
                        enabled: false
                        checkable: true
                        checked: false
                        ButtonGroup.group: resultsgroup
                        onClicked: {
                            listmodelfullintegrals.setProperty(0, 'mytext', 'S0 ' + Math.round((pair0chsen.integral - pair0chche.integral * acr0.realValue) * calib0.realValue * 100)/100)
                            listmodelfullintegrals.setProperty(1, 'mytext', '')
                            listmodelfullintegrals.setProperty(2, 'mytext', 'S1 ' + Math.round((pair1chsen.integral - pair1chche.integral * acr1.realValue) * calib1.realValue * 100)/100)
                            listmodelfullintegrals.setProperty(3, 'mytext', '')
                            listmodelfullintegrals.setProperty(4, 'mytext', 'S2 ' + Math.round((pair2chsen.integral - pair2chche.integral * acr2.realValue) * calib2.realValue * 100)/100)
                            listmodelfullintegrals.setProperty(5, 'mytext', '')
                            listmodelfullintegrals.setProperty(6, 'mytext', 'S3 ' + Math.round((pair3chsen.integral - pair3chche.integral * acr3.realValue) * calib3.realValue * 100)/100)
                            listmodelfullintegrals.setProperty(7, 'mytext', '')
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

            ListModel {
               id: listmodelfullintegrals
               ListElement {
                   mycolor: 'red'
                   fullintegral: 0
                   chargedose: 0
                   dose: 0
                   mytext: 'ch0'
                }
                ListElement {
                    mycolor: 'lightblue'
                    fullintegral: 0
                    chargedose: 0
                    dose: 0
                    mytext: 'ch1'
                }
                ListElement {
                    mycolor: 'lightgreen'
                    fullintegral: 0
                    chargedose: 0
                    dose: 0
                    mytext: 'ch2'
                }
                ListElement {
                    mycolor: 'yellow'
                    fullintegral: 0
                    chargedose: 0
                    dose: 0
                    mytext: 'ch3'
                }
                ListElement {
                     mycolor: 'cyan'
                     fullintegral: 0
                     chargedose: 0
                     dose: 0
                     mytext: 'ch4'
                }
                ListElement {
                     mycolor: 'fuchsia'
                     fullintegral: 0
                     chargedose: 0
                     dose: 0
                     mytext: 'ch5'
                }
                ListElement {
                     mycolor: 'orange'
                     fullintegral: 0
                     chargedose: 0
                     dose: 0
                     mytext: 'ch6'
                }
                ListElement {
                     mycolor: 'lightgrey'
                     fullintegral: 0
                     chargedose: 0
                     dose: 0
                     mytext: 'ch7'
                }
              }

            ListModel {
               id: integralsmodel
               ListElement {
                   mycolor: 'red'
                   intvalue: 0
                   mytext: 'ch0'
               }
               ListElement {
                   mycolor: 'lightblue'
                   intvalue: 0
                   mytext: 'ch1'
               }
               ListElement {
                    mycolor: 'lightgreen'
                    intvalue: 0
                    mytext: 'ch2'
               }
               ListElement {
                    mycolor: 'yellow'
                    intvalue: 0
                    mytext: 'ch3'
               }
               ListElement {
                    mycolor: 'cyan'
                    intvalue: 0
                    mytext: 'ch4'
               }
               ListElement {
                    mycolor: 'fuchsia'
                    intvalue: 0
                    mytext: 'ch5'
               }
               ListElement {
                    mycolor: 'orange'
                    intvalue: 0
                    mytext: 'ch6'
               }
               ListElement {
                    mycolor: 'lightgrey'
                    intvalue: 0
                    mytext: 'ch7'
               }
             }

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
                        model: listmodelfullintegrals

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
                                    text: mytext
                                    color: 'lightgrey'
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    Text {
                        id: unitsfullintegrals
                        text: (chargebt.checked | chargedosebt.checked) ? '(nC)' : '(cGy)'
                        color: 'lightgrey'
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
                //titleText: 'Voltage (V)'
                titleText: 'Currrent (nA)'
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
                property bool activezoom: false

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
                            model: integralsmodel

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
                                        text: mytext
                                        color: 'lightgrey'
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        Text {
                            id: integralsunits
                            text: (chargebt.checked | chargedosebt.checked) ? '(nC)' : '(cGy)'
                            color: 'lightgrey'

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
                                if (chargebt.checked){
                                    for (var j = 0; j < 8; j++){
                                       //console.log('ch' + j + ' object name at ' + i + ' is ' + typeof (Math.round(lqmlchs[j].listaint[i]*100)/100))
                                      integralsmodel.setProperty(j, 'mytext', 'ch' + j + ' ' + Math.round(lqmlchs[j].listaint[i] * 100)/100)
                                    }
                                }
                                if (chargedosebt.checked){
                                    integralsmodel.setProperty(0, 'mytext', 'S0 ' + Math.round((pair0chsen.listaint[i] - pair0chche.listaint[i] * acr0.realValue)* 100)/100)
                                    integralsmodel.setProperty(1, 'mytext', '')
                                    integralsmodel.setProperty(2, 'mytext', 'S1 ' + Math.round((pair1chsen.listaint[i] - pair1chche.listaint[i] * acr1.realValue)* 100)/100)
                                    integralsmodel.setProperty(3, 'mytext', '')
                                    integralsmodel.setProperty(4, 'mytext', 'S2 ' + Math.round((pair2chsen.listaint[i] - pair2chche.listaint[i] * acr2.realValue)* 100)/100)
                                    integralsmodel.setProperty(5, 'mytext', '')
                                    integralsmodel.setProperty(6, 'mytext', 'S3 ' + Math.round((pair3chsen.listaint[i] - pair3chche.listaint[i] * acr3.realValue)* 100)/100)
                                    integralsmodel.setProperty(7, 'mytext', '')
                                }
                                if (dosebt.checked){
                                    integralsmodel.setProperty(0, 'mytext', 'S0 ' + Math.round((pair0chsen.listaint[i] - pair0chche.listaint[i] * acr0.realValue) * calib0.realValue * 100)/100)
                                    integralsmodel.setProperty(1, 'mytext', '')
                                    integralsmodel.setProperty(2, 'mytext', 'S1 ' + Math.round((pair1chsen.listaint[i] - pair1chche.listaint[i] * acr1.realValue) * calib1.realValue * 100)/100)
                                    integralsmodel.setProperty(3, 'mytext', '')
                                    integralsmodel.setProperty(4, 'mytext', 'S2 ' + Math.round((pair2chsen.listaint[i] - pair2chche.listaint[i] * acr2.realValue) * calib2.realValue * 100)/100)
                                    integralsmodel.setProperty(5, 'mytext', '')
                                    integralsmodel.setProperty(6, 'mytext', 'S3 ' + Math.round((pair3chsen.listaint[i] - pair3chche.listaint[i] * acr3.realValue) * calib3.realValue * 100)/100)
                                    integralsmodel.setProperty(7, 'mytext', '')
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
                        ma.activezoom = true
                        xstart = false
                        zoomarea.visible = false
                    }
                }

                onClicked: {
                    if (mouse.button & Qt.RightButton) {
                        chartviewchs.zoomReset()
                        ma.activezoom = false
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
        property real ch0
        property real ch1
        property real ch2
        property real ch3
        property real ch4
        property real ch5
        property real ch6
        property real ch7
        property real ps
        property real v5
        property real minus12V
        property real vref

        onSignaldatain: {
            time = lista[0]
            if (time > 60 & ma.activezoom === false) {
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


            //var ch0 = -lista[2]  * 20.48 / 65535 + 10.24
            var ch0 = (-lista[2]  * 20.48 / 65535 + 10.24) * 1.8 / 300e-3
            if (axisYch.first == true) {
                axisYch.min = ch0 - 0.005
                axisYch.max = ch0 + 0.005
            }
            else {
                if (ch0 > axisYch.max & ma.activezoom === false) {axisYch.max = ch0 + 0.005}
                if (ch0 < axisYch.min & ma.activezoom === false) {axisYch.min = ch0 - 0.005}
            }

           //var ch1 = -lista[3]  * 20.48 / 65535 + 10.24
            var ch1 = (-lista[3]  * 20.48 / 65535 + 10.24) * 1.8 / 300e-3
            if (axisYch.first == true) {
                axisYch.min = ch1 - 0.005
                axisYch.max = ch1 + 0.005
            }
            else {
                if (ch1 > axisYch.max & ma.activezoom === false) {axisYch.max = ch1 + 0.005}
                if (ch1 < axisYch.min & ma.activezoom === false) {axisYch.min = ch1 - 0.005}
            }

            //var ch2 = -lista[4]  * 20.48 / 65535 + 10.24
            var ch2 = (-lista[4]  * 20.48 / 65535 + 10.24) * 1.8 / 300e-3
            if (axisYch.first == true) {
                axisYch.min = ch2 - 0.005
                axisYch.max = ch2 + 0.005
            }
            else {
                if (ch2 > axisYch.max & ma.activezoom === false) {axisYch.max = ch2 + 0.005}
                if (ch2 < axisYch.min & ma.activezoom === false) {axisYch.min = ch2 - 0.005}
            }

            //var ch3 = -lista[5]  * 20.48 / 65535 + 10.24
            var ch3 = (-lista[5]  * 20.48 / 65535 + 10.24) * 1.8 / 300e-3
            if (axisYch.first == true) {
                axisYch.min = ch3 - 0.005
                axisYch.max = ch3 + 0.005
            }
            else {
                if (ch3 > axisYch.max & ma.activezoom === false) {axisYch.max = ch3 + 0.005}
                if (ch3 < axisYch.min & ma.activezoom === false) {axisYch.min = ch3 - 0.005}
            }

            //var ch4 = -lista[6]  * 20.48 / 65535 + 10.24
            var ch4 = (-lista[6]  * 20.48 / 65535 + 10.24) * 1.8 / 300e-3
            if (axisYch.first == true) {
                axisYch.min = ch4 - 0.005
                axisYch.max = ch4 + 0.005
            }
            else {
                if (ch4 > axisYch.max & ma.activezoom === false) {axisYch.max = ch4 + 0.005}
                if (ch4 < axisYch.min & ma.activezoom === false) {axisYch.min = ch4 - 0.005}
            }

            //var ch5 = -lista[7]  * 20.48 / 65535 + 10.24
            var ch5 = (-lista[7]  * 20.48 / 65535 + 10.24) * 1.8 / 300e-3
            if (axisYch.first == true) {
                axisYch.min = ch5 - 0.005
                axisYch.max = ch5 + 0.005
            }
            else {
                if (ch5 > axisYch.max & ma.activezoom === false) {axisYch.max = ch5 + 0.005}
                if (ch5 < axisYch.min & ma.activezoom === false) {axisYch.min = ch5 - 0.005}
            }

            //var ch6 = -lista[8]  * 20.48 / 65535 + 10.24
            var ch6 = (-lista[8]  * 20.48 / 65535 + 10.24) * 1.8 / 300e-3
            if (axisYch.first == true) {
                axisYch.min = ch6 - 0.005
                axisYch.max = ch6 + 0.005
            }
            else {
                if (ch6 > axisYch.max & ma.activezoom === false) {axisYch.max = ch6 + 0.005}
                if (ch6 < axisYch.min & ma.activezoom === false) {axisYch.min = ch6 - 0.005}
            }


            //var ch7 = -lista[9]  * 20.48 / 65535 + 10.24
            var ch7 = (-lista[9]  * 20.48 / 65535 + 10.24) * 1.8 / 300e-3
            if (axisYch.first == true) {
                axisYch.min = ch7 - 0.005
                axisYch.max = ch7 + 0.005
                axisYch.first = false
            }
            else {
                if (ch7 > axisYch.max & ma.activezoom === false) {axisYch.max = ch7 + 0.005}
                if (ch7 < axisYch.min & ma.activezoom === false) {axisYch.min = ch7 - 0.005}
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


            var ps = lista[11] * 0.1875 * pscoef.realValue / 1000
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
            chartviewchs.series('ch0').append(time, ch0)
            chartviewchs.series('ch1').append(time, ch1)
            chartviewchs.series('ch2').append(time, ch2)
            chartviewchs.series('ch3').append(time, ch3)
            chartviewchs.series('ch4').append(time, ch4)
            chartviewchs.series('ch5').append(time, ch5)
            chartviewchs.series('ch6').append(time, ch6)
            chartviewchs.series('ch7').append(time, ch7)
            line5V.append(time, v5)
            linePS.append(time, ps)
            lineminus12V.append(time, minus12V)
            linevref.append(time, vref)

        }

    }

    Connections {
        target: limitslines
        onSignallimitsin: {
            //console.log('start times 0: ' + starttimes[0])
            //console.log('finish times 0: ' + finishtimes[0])
            //var lqmlchs = [qmlch0, qmlch1, qmlch2, qmlch3, qmlch4, qmlch5, qmlch6, qmlch7]

            for (var i = 0; i < starttimes.length; i++){
                var starlimit = chartviewchs.createSeries(ChartView.SeriesTypeLine, 'start' + i, axisXch, axisYch)
                starlimit.color = 'lightgreen'
                starlimit.style = Qt.DashLine
                starlimit.append (starttimes[i] - 1, axisYch.min)
                starlimit.append (starttimes[i] - 1 , axisYch.max)
            }

            for (var j = 0; j < finishtimes.length; j++){
                var finishlimit = chartviewchs.createSeries(ChartView.SeriesTypeLine, 'finish' + j, axisXch, axisYch)
                finishlimit.color = 'lightsalmon'
                finishlimit.style = Qt.DashLine
                finishlimit.append (finishtimes[j] + 1, axisYch.min)
                finishlimit.append (finishtimes[j] + 1 , axisYch.max)
            }

            axisYch.min = 0
            ma.starttimes = starttimes
            ma.finishtimes = finishtimes
            for (var x = 0; x < 8; x++){
                listmodelfullintegrals.setProperty(x, 'mytext', 'ch' + x + ' ' + Math.round(lqmlchs[x].integral * 100)/100 )
            }


            for (var k = 0; k < 8; k++){
                lqmlchs[k].update_serie(chartviewchs.series('ch' + k))
            }

        }
    }

    Connections {
        target: analyzelimitslines
        onSignallimitsin: {
            //console.log('starttimes 0: ' + starttimes[0])
            //console.log('finishtimes length: ' + finishtimes[finishtimes.length - 1])
            //console.log('integrals ch0: ' + lqmlanalyzechs[0].listaint)
            console.log('maximum temp: ' + analyzetemp.maxplot)

            analyzeaxisXch.max = finishtimes[finishtimes.length - 1] + 5
            analyzeaxisYch.min = qmlchanalyze0.minplot
            analyzeaxisYch.max = qmlchanalyze0.maxplot
            analyzeaxisX5V.max = finishtimes[finishtimes.length - 1] + 5
            analyzeaxisY5V.max = analyze5v.maxplot
            analyzeaxisY5V.min = analyze5v.minplot
            analyzeaxisXPS.max = finishtimes[finishtimes.length - 1] + 5
            analyzeaxisYPS.max = analyzePS.maxplot
            analyzeaxisYPS.min = analyzePS.minplot
            analyzeaxisXminus12V.max = finishtimes[finishtimes.length - 1] + 5
            analyzeaxisYminus12V.max = analyzeminus12v.maxplot
            analyzeaxisYminus12V.min =  analyzeminus12v.minplot
            analyzeaxisXvref.max = finishtimes[finishtimes.length - 1] + 5
            analyzeaxisYvref.max = analyzevref.maxplot
            analyzeaxisYvref.min = analyzevref.minplot
            analyzeaxisXtemp.max = finishtimes[finishtimes.length - 1] + 5
            analyzeaxisYtemp.max = analyzetemp.maxplot
            analyzeaxisYtemp.min = analyzetemp.minplot

            for (var i = 0; i < starttimes.length; i++){
                var starlimit = analyzechartviewchs.createSeries(ChartView.SeriesTypeLine, 'start' + i, analyzeaxisXch, analyzeaxisYch)
                starlimit.color = 'lightgreen'
                starlimit.style = Qt.DashLine
                starlimit.append (starttimes[i] - 1, analyzeaxisYch.min)
                starlimit.append (starttimes[i] - 1, analyzeaxisYch.max)
            }

            for (var j = 0; j < finishtimes.length; j++){
                var finishlimit = analyzechartviewchs.createSeries(ChartView.SeriesTypeLine, 'finish' + j, analyzeaxisXch, analyzeaxisYch)
                finishlimit.color = 'lightsalmon'
                finishlimit.style = Qt.DashLine
                finishlimit.append (finishtimes[j] + 1, analyzeaxisYch.min)
                finishlimit.append (finishtimes[j] + 1, analyzeaxisYch.max)
            }

            analyzema.analyzestarttimes = starttimes
            analyzema.analyzefinishtimes = finishtimes
            for (var x = 0; x < 8; x++){
                analyzelistmodelfullintegrals.setProperty(x, 'mytext', 'ch' + x + ' ' + Math.round(lqmlanalyzechs[x].integral * 100)/100 )
            }

            for (var k = 0; k < 8; k++){
                lqmlanalyzechs[k].update_serie(analyzechartviewchs.series('ch' + k))
            }

            analyzetemp.update_serie(analyzelinetemp)
            analyzePS.update_serie(analyzelinePS)
            analyze5v.update_serie(analyzeline5V)
            analyzeminus12v.update_serie(analyzelineminus12V)
            analyzevref.update_serie(analyzelinevref)

        }
    }

}

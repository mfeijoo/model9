#!/usr/bin/env python3
#branch master

#########################################################################
#                           IMPORTS                                     #
#########################################################################

#from PyQt5 import QtCore
import sys
import os
os.environ["QT_IM_MODULE"] = "qtvirtualkeyboard"
#os.environ["QT_VIRTUALKEYBOARD_STYLE"] = "retro"
os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
#print (os.environ)
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import QThread, pyqtSignal, QObject, pyqtSlot, pyqtProperty, QPointF
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtChart import QXYSeries
import time
import serial
import serial.tools.list_ports
import pandas as pd
import numpy as np
import atexit
#from PyQt5.QtQuick import QQuickView

#########################################################################
#                      GLOBAL VARIABLES                                 #
#########################################################################

#Create the global lists of measurements
timemeas = []
PSmeas = []
minus12Vmeas = []
v5Vmeas = []
vrefVmeas = []

#########################################################################
#                    GLOBAL FUNCTIONS                                   #
#########################################################################

#From signal info update the lists with all measurements
def update(lista):
    global timemeas, PSmeas, minus12Vmeas, v5Vmeas, vrefmeas
    for ch in dchs.values():
        ch.time.append(lista[0])
        ch.temp.append(lista[1])
        ch.meas.append(lista[ch.num+2])
    timemeas.append(lista[0])
    PSmeas.append(lista[len(dchs)+3])
    minus12Vmeas.append(lista[len(dchs)+4])
    v5Vmeas.append(lista[len(dchs)+2])
    vrefVmeas.append(lista[len(dchs)+5])
def from_gui_to_dic():
    dmetadata['Power Supply'] = str(psspinbox.property('value')/100)
    if sendtocontrollerbt.property('enabled') == False:
        dmetadata['Integration Time'] = str(integrationtimespinbox.property('value'))
        dmetadata['Operational Mode'] = integrationpulseswitch.property('text')
    dmetadata['File Name'] = filenamefromqml.property('text')
    dmetadata['Pair 0 Ch Sensor'] = 'ch%s' % pair0chsensor.property('currentIndex')
    dmetadata['Pair 0 Ch Cherenkov'] = 'ch%s' % pair0chcherenkov.property('currentIndex')
    dmetadata['Pair 1 Ch Sensor'] = 'ch%s' % pair1chsensor.property('currentIndex')
    dmetadata['Pair 1 Ch Cherenkov'] = 'ch%s' % pair1chcherenkov.property('currentIndex')
    dmetadata['Pair 2 Ch Sensor'] = 'ch%s' % pair2chsensor.property('currentIndex')
    dmetadata['Pair 2 Ch Cherenkov'] = 'ch%s' % pair2chcherenkov.property('currentIndex')
    dmetadata['Pair 3 Ch Sensor'] = 'ch%s' % pair3chsensor.property('currentIndex')
    dmetadata['Pair 3 Ch Cherenkov'] = 'ch%s' % pair3chcherenkov.property('currentIndex')
    dmetadata['ACR0'] = str(acr0.property('realValue'))
    dmetadata['ACR1'] = str(acr1.property('realValue'))
    dmetadata['ACR2'] = str(acr2.property('realValue'))
    dmetadata['ACR3'] = str(acr3.property('realValue'))
    dmetadata['Calib0'] = str(calib0.property('realValue'))
    dmetadata['Calib1'] = str(calib1.property('realValue'))
    dmetadata['Calib2'] = str(calib2.property('realValue'))
    dmetadata['Calib3'] = str(calib3.property('realValue'))
    dmetadata['X0'] = str(x0.property('realValue'))
    dmetadata['Y0'] = str(y0.property('realValue'))
    dmetadata['Z0'] = str(z0.property('realValue'))
    dmetadata['X1'] = str(x1.property('realValue'))
    dmetadata['Y1'] = str(y1.property('realValue'))
    dmetadata['Z1'] = str(z1.property('realValue'))
    dmetadata['X2'] = str(x2.property('realValue'))
    dmetadata['Y2'] = str(y2.property('realValue'))
    dmetadata['Z2'] = str(z2.property('realValue'))
    dmetadata['X3'] = str(x3.property('realValue'))
    dmetadata['Y3'] = str(y3.property('realValue'))
    dmetadata['Z3'] = str(z3.property('realValue'))
    dmetadata['Comments'] = commentstext.property('text').replace(',', '')




def from_dic_to_gui():

    #print ('set psspintbox value property to: %s' %dmetadata['Power Supply'])
    filenamefromqml.setProperty('text', dmetadata['File Name'])
    psspinbox.setProperty('value', float(dmetadata['Power Supply']) * 100)
    integrationtimespinbox.setProperty('value', int(dmetadata['Integration Time']))
    sendtocontrollerbt.setProperty('enabled', False)
    if dmetadata['Operational Mode'] == 'Pulse Mode':
        integrationpulseswitch.setProperty('checked', False)
    else:
        integrationpulseswitch.setProperty('checked', True)
    pair0chsensor.setProperty('currentIndex', int(dmetadata['Pair 0 Ch Sensor'][-1]))
    pair0chcherenkov.setProperty('currentIndex', int(dmetadata['Pair 0 Ch Cherenkov'][-1]))
    pair1chsensor.setProperty('currentIndex', int(dmetadata['Pair 1 Ch Sensor'][-1]))
    pair1chcherenkov.setProperty('currentIndex', int(dmetadata['Pair 1 Ch Cherenkov'][-1]))
    pair2chsensor.setProperty('currentIndex', int(dmetadata['Pair 2 Ch Sensor'][-1]))
    pair2chcherenkov.setProperty('currentIndex', int(dmetadata['Pair 2 Ch Cherenkov'][-1]))
    pair3chsensor.setProperty('currentIndex', int(dmetadata['Pair 3 Ch Sensor'][-1]))
    pair3chcherenkov.setProperty('currentIndex', int(dmetadata['Pair 3 Ch Cherenkov'][-1]))
    acr0.setProperty('value', int(float(dmetadata['ACR0'])*10000))
    acr1.setProperty('value', int(float(dmetadata['ACR1'])*10000))
    acr2.setProperty('value', int(float(dmetadata['ACR2'])*10000))
    acr3.setProperty('value', int(float(dmetadata['ACR3'])*10000))
    calib0.setProperty('value', int(float(dmetadata['Calib0'])*10000))
    calib1.setProperty('value', int(float(dmetadata['Calib1'])*10000))
    calib2.setProperty('value', int(float(dmetadata['Calib2'])*10000))
    calib3.setProperty('value', int(float(dmetadata['Calib3'])*10000))
    x0.setProperty('value', int(float(dmetadata['X0'])*100))
    y0.setProperty('value', int(float(dmetadata['Y0'])*100))
    z0.setProperty('value', int(float(dmetadata['Z0'])*100))
    x1.setProperty('value', int(float(dmetadata['X1'])*100))
    y1.setProperty('value', int(float(dmetadata['Y1'])*100))
    z1.setProperty('value', int(float(dmetadata['Z1'])*100))
    x2.setProperty('value', int(float(dmetadata['X2'])*100))
    y2.setProperty('value', int(float(dmetadata['Y2'])*100))
    z2.setProperty('value', int(float(dmetadata['Z2'])*100))
    x3.setProperty('value', int(float(dmetadata['X3'])*100))
    y3.setProperty('value', int(float(dmetadata['Y3'])*100))
    z3.setProperty('value', int(float(dmetadata['Z3'])*100))
    commentstext.setProperty('text', dmetadata['Comments'])


#This is the function to be excuted when clicking
#the start button in qml
def qmlstart():
    global timemeas, PSmeas, minus12Vmeas, v5Vmeas, vrefmeas
    #Prepare the lists to store data
    #first clean up all the lists
    for ch in dchs.values():
        ch.time = []
        ch.temp = []
        ch.meas = []
        timemeas = []
        PSmeas = []
        minus12Vmeas = []
        v5Vmeas = []
        vrefVmeas = []

    #update dmetadata date with teh time and date
    #of the start of measurement
    dmetadata['Date Time'] = time.strftime('%d %b %Y %H:%M:%S')

    #Prepare the file to store all data
    #Check if the file already exist, to prevent overwritting


    #Start the emulator thread
    #Comment if not emulator
    #emulator.start()

    #Start the measurements thread
    measure.start()

def qmlsendtocontroller():
    device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
    serc = serial.Serial(device, 115200, timeout=1)
    inttime = integrationtimespinbox.property('value')
    intpulse = integrationpulseswitch.property('text')
    texttosend = 'c%s,%s' %(inttime, intpulse[0])
    serc.write(texttosend.encode())
    serc.close()
    sendtocontrollerbt.setProperty('enabled', False)

def goodbye():
    print ('bye')
    metadatafile = open('metadata.csv', 'w')
    for key in metadatakeylist:
        metadatafile.write('%s,%s\n' %(key, dmetadata[key]))
        #print ('%s,%s\n' %(key, dmetadata[key]))
    metadatafile.close()



#########################################################################
#                     CLASSES                                           #
#########################################################################

class CH():

    def __init__(self, num):
        self.num = num
        self.name = 'ch%s' %num
        self.time = []
        self.temp = []
        self.meas = []

    def calcintegral(self, starttimes, finishtimes):
        self.df = pd.DataFrame({'time':self.time, 'meas':self.meas, 'temp':self.temp})
        #self.df['measV'] = (-(self.df.meas * 20.48/65535) + 10.24)
        self.df['measA'] = (-(self.df.meas * 20.48/65535) + 10.24) * 1.8 / (int(dmetadata['Integration Time']) * 1e-3)
        #Calculate start and end of radiation
        #self.df['measdiff'] = self.df.meas.diff()
        try:
            self.ts = starttimes.values[0]
            self.tf = finishtimes.values[-1]
        except IndexError:
            self.ts = self.time[0]
            self.tf = self.time[-1]

        #self.df['measVz'] = np.nan
        self.df['measAz'] = np.nan

        #Now we calculate the integrals of each beam and put it in a list
        #Calculating the local zero for each beam
        self.listaint = []
        for (st, ft) in zip(starttimes, finishtimes):
            localzero = self.df.loc[((self.df.time > st-3)&(self.df.time<st-1))|((self.df.time>ft+1)&(self.df.time<ft+3)), 'measA'].mean()
            self.df.loc[(self.df.time > st-3)&(self.df.time<ft+3), 'measAz'] = self.df.loc[(self.df.time > st-3)&(self.df.time<ft+3), 'measA'] - localzero
            intbeamn = self.df.loc[(self.df.time>(st-1))&(self.df.time<(ft+1)), 'measAz'].sum() * (int(dmetadata['Integration Time']) * 1e-3)
            self.listaint.append(float(intbeamn))

        #calculate integral
        self.integral = self.df.measAz.sum() * (int(dmetadata['Integration Time']) * 1e-3)

        self.dftoplot = self.df.dropna()

        #print ('%s integrals: %s' %(self.name, self.listaint))


class CHQml(QObject):

    integralChanged = pyqtSignal(float)
    listaintChanged = pyqtSignal(list)
    nameChanged = pyqtSignal(str)


    def __init__(self, chname, parent=None):
        super().__init__(parent)
        self._name = chname
        self._integral = 0.0
        self._listaint = []
        self.listatimes = []
        self.listavzeros = []

    @pyqtProperty(str, notify=nameChanged)
    def name(self):
        return self._name

    @pyqtProperty(float, notify=integralChanged)
    def integral(self):
        return self._integral

    @integral.setter
    def integral(self, i):
        if self._integral != i:
            self._integral = i
            self.integralChanged.emit(i)

    @pyqtProperty(list, notify=listaintChanged)
    def listaint(self):
        return self._listaint

    @listaint.setter
    def listaint(self, li):
        if self._listaint != li:
            self._listaint = li
            self.listaintChanged.emit(li)

    @pyqtSlot(QXYSeries)
    def update_serie(self, serie):
        points = [QPointF(x,y) for (x,y) in zip(self.listatimes, self.listavzeros)]
        serie.replace(points)



class Listain(QObject):
    signaldatain = pyqtSignal(list, arguments=['lista'])

    def __init__(self, parent=None):
        super().__init__(parent)

    @pyqtSlot(list)
    def lista(self, l):
        self.signaldatain.emit(l)

class LimitsLines(QObject):
    signallimitsin = pyqtSignal(list, list, arguments=['starttimes', 'finishtimes'])

    def __init__(self, parent=None):
        super().__init__(parent)

    @pyqtSlot(list, list)
    def limitsin(self, starttimes, finishtimes):
        self.signallimitsin.emit(starttimes, finishtimes)

class EmulatorThread(QThread):
    
    def __init__(self):
        QThread.__init__(self)
        
    def __del__(self):
        self.wait()
        
    def run(self):
        self.stop = False
        file = open('./rawdata/emulatormeasurmentslong.csv', 'r')
        self.lines =  file.readlines()
        file.close()
        self.ser2 = serial.Serial ('/dev/pts/3', 115200, timeout=1)
        for line in self.lines:
            self.ser2.write(line.encode())
            #print(line)
            if self.stop:
                break
            time.sleep(0.320)
        
        self.ser2.close()
        
    def stopping(self):
        self.stop = True
        self.wait()
        self.quit()
        #print ('emulator stopped')


class RegulatePSThread(QThread):

    signalpsmeas = pyqtSignal(int)

    def __init__(self):
        QThread.__init__(self)

    def __del__(self):
        self.wait()

    def run(self):
        self.stop = False

        #comment next 6 if emulator

        device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        self.serreg = serial.Serial(device, 115200, timeout=2)
        psset = psspinbox.property('realValue')
        self.serreg.write(('r%.2f,' %psset).encode())
        print (('r%.2f,' %psset).encode())
        line = self.serreg.readline().decode().strip().split(',')


        regulateprogressbar.setProperty('value', 0)


        #emulator 13 no emulator 5
        for i in range(5):
            #comment next 2 if emulator
            line = self.serreg.readline().decode().strip().split(',')
            #print (line)
            if len(line) == 6:
                value = float(line[-1])
                regulateprogressbar.setProperty('value', value)
            #comment if not emulator
            #time.sleep(0.5)

        #comment the whole while loop if emulator
        listapots = []
        while (len(line) == 6):

            if self.stop:
                break

            line = self.serreg.readline().decode().strip().split(',')
            value = float(line[-1])
            regulateprogressbar.setProperty('value', value)
            listapots.append(line[3])
            #print (line)

        #print ('Regulating PS is done')
        #print ('lista pots: ', listapots)
        #regulateprogressbar.setProperty('value', 13)
        regulateb.setProperty('checked', False)
        #comment if emulator
        self.serreg.close()
        dmetadata['PS Pot'] = listapots[-2]


    def stopping(self):
        self.stop = True
        #comment if emulator
        self.serreg.close()
        self.wait()
        self.quit()
        #print('Regulate PS stopoped')


class SubtractDcThread(QThread):

    def __init__(self):
        QThread.__init__(self)

    def __del__(self):
        self.wait()

    def run(self):
        #comment next 3 if emulator
        device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        self.ser = serial.Serial(device, 115200, timeout=1)
        self.ser.write('s'.encode())
        #uncoment if emulator
        #value = 0
        for i in range(3):
            #comment next 2 if emulator

            line = self.ser.readline().decode().strip().split(',')
            value = int(line[0])

            #print (line)

            #change this part for not emulator
            sdcprogressbar.setProperty('value', value)
            #value = value + 1
            #time.sleep(0.5)

        #comment the whole while loop if emulator
        dclines = []
        while len(line) == 9:
            line = self.ser.readline().decode().strip().split(',')
            sdcprogressbar.setProperty('value', int(line[0]))
            dclines.append([line[0], line[4]])

        sdcprogressbar.setProperty('value', 8)
        subtractdcb.setProperty('checked', False)
        #comment if emulator
        self.ser.close()
        #Record all the values of darkcurrent for all channels and put in metadata
        dfdc = pd.DataFrame(dclines, columns=['ch', 'dcvalue'])
        dfdc.drop(dfdc.index[-1], inplace=True)
        listadcvalues = dfdc.groupby('ch').apply(lambda x: x.iloc[-1,-1]).tolist()
        print (listadcvalues)
        for i, value in enumerate(listadcvalues):
            dmetadata['Dark Current Ch%s' %i] = value



    def stopping(self):
        self.stop = True
        #comment if emulator
        self.ser.close()
        self.wait()
        self.quit()
        #print('measure stopoped')


class MeasureThread(QThread):

    info = pyqtSignal (list)

    def __init__(self):
        QThread.__init__(self)

    def __del__(self):
        self.wait()

    def run(self):
        self.stop = False
        #emulator
        #self.ser = serial.Serial ('/dev/pts/4', 115200, timeout=1)
        device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        self.ser = serial.Serial (device, 115200, timeout=1)
        #readings to discard garbge

        reading0 = self.ser.readline().decode().strip().split(',')

        #next reading to check starting time
        #comment if emulator
        reading1 = self.ser.readline().decode().strip().split(',')
        tstart = int(reading1[0])
        
        while True:
            
            if self.stop:
                break


            try:
                reading = self.ser.readline().decode().strip().split(',')
                #print (reading)
                #comment if not emulator
                #listatosend = [float(reading[0])] + [int(i) for i in reading[1:]]
                listatosend = [(int(reading[0]) - tstart)/1000]+[float(reading[1])]+[int(i) for i  in reading[2:]]
                #print (listatosend)
                self.info.emit(listatosend)
            except (TypeError, ValueError):
                pass




    def stopping(self):
        self.stop = True
        self.ser.close()
        self.wait()
        self.quit()
        #print('measure stopoped')
    
#This is the function to be executed when clicking
#stop button in qml
class StopThread(QThread):

    signallimitslists = pyqtSignal (list, list)

    def __init__(self):
        QThread.__init__(self)

    def __del__(self):
        self.wait()

    def run(self):

        #stop the emulator thread
        #comment if not emulator
        #emulator.stopping()

        #stop the regulate ps
        if regulateps.isRunning():
            regulateps.stopping()

        #stop the measure thread
        if measure.isRunning():
            measure.stopping()

        #Right after stopping
        #dump all the data in a .cvs file
        #Open the file to dump all the data
        filemeas = open ('./rawdata/%s.csv' %dmetadata['File Name'], 'w')

        #Put in the header of the file the metadata information
        for key in metadatakeylist:
            filemeas.write('%s,%s\n' %(key,dmetadata[key]))

        filemeas.write('time,temp,%s,PS,-12V,5V,refV\n' %','.join([ch for ch in sorted(dchs)]))
        #print ('timemeas: %s' %timemeas)
        #print ('temperatures: %s' %dchs['ch0'].temp)
        for i in range(len(timemeas)):
            line1 = '%s,%.4f' %(timemeas[i], dchs['ch0'].temp[i])
            line2 = ','.join(['%s' %dchs[ch].meas[i] for ch in sorted(dchs)])
            line3 = '%s,%s,%s,%s' %(PSmeas[i], minus12Vmeas[i], v5Vmeas[i], vrefVmeas[i])
            filemeas.write('%s,%s,%s\n' %(line1, line2, line3))

        #Once all the data has been dumped
        #close the file
        filemeas.close()

        #Now let's calculate the limit times of each shot
        #monitor channel will be the channel wiht maximum measurement
        mch = 'ch0'
        for ch in sorted(dchs):
            if min(dchs[ch].meas) < min(dchs[mch].meas):
                mch = ch
        print ('the monitor channel is: %s' %mch)

        #lets find the start and stop of all beams
        dff = pd.DataFrame({'time':dchs[mch].time, mch:dchs[mch].meas})
        dff['chdiff'] = dff[mch].diff()
        dffchanges =  dff.loc[dff.chdiff.abs() > 1000, :].copy()
        dffchanges['timediff'] = dffchanges.time.diff()
        dffchanges.fillna(1, inplace=True)
        dfftimes =  dffchanges[dffchanges.timediff > 0.5].copy()
        #print (dfftimes.head())
        starttimes = dfftimes.loc[dfftimes.chdiff < 0, 'time']
        #print (starttimes)
        finishtimes = dfftimes.loc[dfftimes.chdiff > 0, 'time']
        #print (finishtimes)

        #Calculate the integrals in each region
        #and update the information in the dqmlchs objects

        for key, ch in dchs.items():
            ch.calcintegral(starttimes, finishtimes)
            dqmlchs[key]._integral = ch.integral
            dqmlchs[key]._listaint = ch.listaint
            dqmlchs[key].listatimes = ch.dftoplot.time.tolist()
            #dqmlchs[key].listavzeros = ch.dftoplot.measVz.tolist()
            dqmlchs[key].listavzeros = ch.dftoplot.measAz.tolist()

        #send to qml the limits to plot in chartview
        self.signallimitslists.emit(list(starttimes), list(finishtimes))



#########################################################################
#            CREATE PYTHON OBJECTS                                      #
#########################################################################

#Create a qml object to update qml with teh list of measurements
listain = Listain()
mylimitslines = LimitsLines()
regulateps = RegulatePSThread()
mysubtractdc = SubtractDcThread()
mystopthread = StopThread()
#create the channels based in the number of channels
number_of_ch = 8
dchs = {'ch%s' %i : CH(i) for i in range(number_of_ch)}
#create python objects to be ready to push to qml for each channel
dqmlchs = {'ch%s' %i : CHQml('ch%s' %i) for i in range(number_of_ch)}
#Create the emulator thread
#Comment if not emulator
#emulator = EmulatorThread()
#Create the measure thread
measure = MeasureThread()
#From metadata.csv file create a dic with current metadata
metadatafile = open('metadata.csv', 'r')
listmetadata = [pair.split(',') for pair in metadatafile.readlines()]
metadatakeylist = [key for [key, value] in listmetadata]
metadatafile.close()
dmetadata = {key:value.strip() for [key,value] in listmetadata}

#########################################################################
#            QML ENGINE                                                 #
#########################################################################


#Create the main app
app = QApplication(sys.argv)

#create the qml engine
engine = QQmlApplicationEngine()


#########################################################################
#            PUSH OBJECTS TO QML ENGINE                                 #
#########################################################################

#include the listain object as a qml object
engine.rootContext().setContextProperty('listain', listain)

engine.rootContext().setContextProperty('limitslines', mylimitslines)

#push the qmlchs objects to qml file
for i, qmlch in enumerate(dqmlchs.values()):
    engine.rootContext().setContextProperty('qmlch%s' %i, qmlch)


#########################################################################
#            LOAD QML FILE TO ENGINE                                    #
#########################################################################

#Load the qmlfile
engine.load('bluephysics.qml')

#########################################################################
#            GET OBJECTS FROM QML ENGINE                                #
#########################################################################

metadatabutton = engine.rootObjects()[0].findChild(QObject, 'metadatabutton')
#Create an object from qml linked to the integration time spinbox
integrationtimespinbox = engine.rootObjects()[0].findChild(QObject, 'integrationtimespinbox')
#Create an object from qml linked to the power supply spinbox
psspinbox = engine.rootObjects()[0].findChild(QObject, 'psspinbox')
#Create an object from qml linked to the start button
startb = engine.rootObjects()[0].findChild(QObject, 'startbutton')
#Create an object in python from qml linked to the stop button
stopb = engine.rootObjects()[0].findChild(QObject, 'stopbutton')
#Create and object in python from qml linked to the home metadata button
metadatabacktohome = engine.rootObjects()[0].findChild(QObject, 'metadatabacktohome')
regulateb = engine.rootObjects()[0].findChild(QObject, 'regulatebutton')
filenamefromqml = engine.rootObjects()[0].findChild(QObject, 'filename')
regulateprogressbar = engine.rootObjects()[0].findChild(QObject, 'regulateprogressbar')
subtractdcb = engine.rootObjects()[0].findChild(QObject, 'subtractdcb')
sdcprogressbar = engine.rootObjects()[0].findChild(QObject, 'sdcprogressbar')
integrationtimespinbox = engine.rootObjects()[0].findChild(QObject, 'integrationtimespinbox')
integrationpulseswitch = engine.rootObjects()[0].findChild(QObject, 'integrationpulseswitch')
sendtocontrollerbt = engine.rootObjects()[0].findChild(QObject, 'sendtocontrollerbt')
pair0chsensor = engine.rootObjects()[0].findChild(QObject, 'pair0chsensor')
pair0chcherenkov = engine.rootObjects()[0].findChild(QObject, 'pair0chcherenkov')
pair1chsensor = engine.rootObjects()[0].findChild(QObject, 'pair1chsensor')
pair1chcherenkov = engine.rootObjects()[0].findChild(QObject, 'pair1chcherenkov')
pair2chsensor = engine.rootObjects()[0].findChild(QObject, 'pair2chsensor')
pair2chcherenkov = engine.rootObjects()[0].findChild(QObject, 'pair2chcherenkov')
pair3chsensor = engine.rootObjects()[0].findChild(QObject, 'pair3chsensor')
pair3chcherenkov = engine.rootObjects()[0].findChild(QObject, 'pair3chcherenkov')
acr0 = engine.rootObjects()[0].findChild(QObject, 'acr0')
acr1 = engine.rootObjects()[0].findChild(QObject, 'acr1')
acr2 = engine.rootObjects()[0].findChild(QObject, 'acr2')
acr3 = engine.rootObjects()[0].findChild(QObject, 'acr3')
calib0 = engine.rootObjects()[0].findChild(QObject, 'calib0')
calib1 = engine.rootObjects()[0].findChild(QObject, 'calib1')
calib2 = engine.rootObjects()[0].findChild(QObject, 'calib2')
calib3 = engine.rootObjects()[0].findChild(QObject, 'calib3')
x0 = engine.rootObjects()[0].findChild(QObject, 'x0')
y0 = engine.rootObjects()[0].findChild(QObject, 'y0')
z0 = engine.rootObjects()[0].findChild(QObject, 'z0')
x1 = engine.rootObjects()[0].findChild(QObject, 'x1')
y1 = engine.rootObjects()[0].findChild(QObject, 'y1')
z1 = engine.rootObjects()[0].findChild(QObject, 'z1')
x2 = engine.rootObjects()[0].findChild(QObject, 'x2')
y2 = engine.rootObjects()[0].findChild(QObject, 'y2')
z2 = engine.rootObjects()[0].findChild(QObject, 'z2')
x3 = engine.rootObjects()[0].findChild(QObject, 'x3')
y3 = engine.rootObjects()[0].findChild(QObject, 'y3')
z3 = engine.rootObjects()[0].findChild(QObject, 'z3')
commentstext = engine.rootObjects()[0].findChild(QObject, 'commentstext')




#########################################################################
#            SIGNALS                                                    #
#########################################################################

metadatabutton.clicked.connect(from_dic_to_gui)
mystopthread.signallimitslists.connect(mylimitslines.limitsin)

#info is the signal created with every measurements
#updatea listain qml object to update graphs in qml
measure.info.connect(listain.lista)

#also use the update function to update the python lists
#and then save all measurements in a file
measure.info.connect(update)

psspinbox.valueModified.connect(from_gui_to_dic)

#link the start button signal with the qmlstart function in python
startb.clicked.connect(qmlstart)

#Connect the signal click from the stop button in qml
#to the python funcition called qmlstop
stopb.clicked.connect(mystopthread.start)

metadatabacktohome.clicked.connect(from_gui_to_dic)

regulateb.clicked.connect(regulateps.start)

subtractdcb.clicked.connect(mysubtractdc.start)

sendtocontrollerbt.clicked.connect(qmlsendtocontroller)

#########################################################################
#            THINGS TO DO AT START                                      #
#########################################################################

#Now form dmetadata dic update the GUI
from_dic_to_gui()

#########################################################################
#            THINGS TO DO AT EXIT                                       #
#########################################################################


atexit.register(goodbye)

#########################################################################
#            CLOSE ENGINE AND APP                                       #
#########################################################################

#Close qml engine if the app is closed
engine.quit.connect(app.quit)
sys.exit(app.exec_())

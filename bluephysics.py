#!/usr/bin/env python3
#branch master

#from PyQt5 import QtCore
import sys
import os
os.environ["QT_IM_MODULE"] = "qtvirtualkeyboard"
#os.environ["QT_VIRTUALKEYBOARD_STYLE"] = "retro"
os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
#print (os.environ)
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import QThread, pyqtSignal, QObject, pyqtSlot, pyqtProperty
from PyQt5.QtQml import QQmlApplicationEngine
import time
import serial
import serial.tools.list_ports
import pandas as pd
import numpy as np
#from PyQt5.QtQuick import QQuickView

#Create the global lists of measurements
timemeas = []
PSmeas = []
minus12Vmeas = []
v5Vmeas = []
vrefVmeas = []

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


class CH():

    def __init__(self, num):
        self.num = num
        self.name = 'ch%s' %num
        self.time = []
        self.temp = []
        self.meas = []

    def calcintegral(self, starttimes, finishtimes):
        self.df = pd.DataFrame({'time':self.time, 'meas':self.meas, 'temp':self.temp})
        self.df['measV'] = (-(self.df.meas * 20.48/65535) + 10.24)
        #self.df['measnC'] = (-(self.df.meas * 20.48/65535) + 10.24) * 1.8
        #Calculate start and end of radiation
        #self.df['measdiff'] = self.df.meas.diff()
        try:
            self.ts = starttimes.values[0]
            self.tf = finishtimes.values[-1]
        except IndexError:
            self.ts = self.time[0]
            self.tf = self.time[-1]
        #correct temperature
        #self.df['meastc'] = self.df.loc[self.df.meas<1, 'meas'] - 0.2318 * (self.df.loc[self.df.meas<1, 'temp'] - 27)
        #self.df.loc[self.df.meas>=1, 'meastc'] = self.df.loc[self.df.meas>=1, 'meas'] - 0.087 * (self.df.loc[self.df.meas>=1, 'temp'] -27)
        #subtract zero
        #self.df['measnCz'] = self.df.measnC - self.df.loc[(self.df.time<(self.ts-2))|(self.df.time>(self.tf+2)), 'measnC'].mean()
        #self.zero = self.df.loc[(self.df.time<(self.ts-2))|(self.df.time>(self.tf+2)), 'measV'].mean()
        self.df['measVz'] = np.nan
        #self.df['measz'] = self.df.meas - self.df.loc[self.df.time < 5, 'meas'].mean()
        #calculate integral
        #self.integral = self.df.loc[(self.df.time>(self.ts-2))&(self.df.time<(self.tf+2)), 'measVz'].sum()
        #self.integral = self.df.loc[:, 'measz'].sum()
        #put the full plot
        #self.viewplot()

        #Now we calculate the integrals of each beam and put it in a list
        #Calculating the local zero for each beam
        self.listaint = []
        for (st, ft) in zip(starttimes, finishtimes):
            localzero = self.df.loc[((self.df.time > st-3)&(self.df.time<st-1))|((self.df.time>ft+1)&(self.df.time<ft+3)), 'measV'].mean()
            self.df.loc[(self.df.time > st-3)&(self.df.time<ft+3), 'measVz'] = self.df.loc[(self.df.time > st-3)&(self.df.time<ft+3), 'measV'] - localzero
            intbeamn = self.df.loc[(self.df.time>(st-1))&(self.df.time<(ft+1)), 'measVz'].sum()
            self.listaint.append(float(intbeamn))

        #calculate integral
        self.integral = self.df.measVz.sum()

        print ('%s integrals: %s' %(self.name, self.listaint))


class CHQml(QObject):

    integralChanged = pyqtSignal(float)
    listaintChanged = pyqtSignal(list)


    def __init__(self, parent=None):
        super().__init__(parent)
        self._integral = 0.0
        self._listaint = []
        self._listatimes = []
        self._listavzeros = []

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
        print ('emulator stopped')


class RegulatePSThread(QThread):

    signalpsmeas = pyqtSignal(int)

    def __init__(self):
        QThread.__init__(self)

    def __del__(self):
        self.wait()

    def run(self):
        self.stop = False

        #comment next 6 if emulator
        #device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        #self.serreg = serial.Serial(device, 115200, timeout=1)
        #psset = psspinbox.property('realValue')
        #self.serreg.write(('r%.2f,' %psset).encode())
        #print (('r%.2f,' %psset).encode())
        #line = self.serreg.readline().decode().strip().split(',')

        regulateprogressbar.setProperty('value', 0)

        value = 0
        #emulator 13 no emulator 5
        for i in range(13):
            #comment next 2 if emulator
            #line = self.serreg.readline().decode().strip().split(',')
            #print (line)
            regulateprogressbar.setProperty('value', value)
            value = value + 1
            #comment if not emulator
            time.sleep(0.5)

        #comment the whole while loop if emulator
        '''while len(line) == 10:

            if self.stop:
                break

            line = self.serreg.readline().decode().strip().split(',')
            regulateprogressbar.setProperty('value', value)
            value = value + 1
            print (line)'''

        regulateprogressbar.setProperty('value', 13)
        regulateb.setProperty('checked', False)
        #comment if emulator
        #self.serreg.close()


    def stopping(self):
        self.stop = True
        #comment if emulator
        #self.serreg.close()
        self.wait()
        self.quit()
        print('Regulate PS stopoped')


class SubtractDcThread(QThread):

    def __init__(self):
        QThread.__init__(self)

    def __del__(self):
        self.wait()

    def run(self):
        #comment next 3 if emulator
        #device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        #self.ser = serial.Serial(device, 115200, timeout=1)
        #self.ser.write('s'.encode())
        #uncoment if emulator
        value = 0
        for i in range(3):
            #comment next 2 if emulator
            #line = self.ser.readline().decode().strip().split(',')
            #print (line)

            #change this part for not emulator
            sdcprogressbar.setProperty('value', value)
            value = value + 1
            time.sleep(0.5)

        #comment the whole while loop if emulator
        '''while len(line) == 9:
            line = self.ser.readline().decode().strip().split(',')
            sdcprogressbar.setProperty('value', int(line[0]))
            print(line)'''

        sdcprogressbar.setProperty('value', 8)
        subtractdcb.setProperty('checked', False)
        #comment if emulator
        #self.ser.close()

    def stopping(self):
        self.stop = True
        #comment if emulator
        #self.ser.close()
        self.wait()
        self.quit()
        print('measure stopoped')


class MeasureThread(QThread):

    info = pyqtSignal (list)

    def __init__(self):
        QThread.__init__(self)

    def __del__(self):
        self.wait()

    def run(self):
        self.stop = False
        #emulator
        self.ser = serial.Serial ('/dev/pts/4', 115200, timeout=1)
        #device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        #self.ser = serial.Serial (device, 115200, timeout=1)
        #One reading to discard garbge
        reading0 = self.ser.readline().decode().strip().split(',')

        #second reading to check starting time
        #comment if emulator
        #reading1 = self.ser.readline().decode().strip().split(',')
        #tstart = int(reading1[0])
        
        while True:
            
            if self.stop:
                break


            try:
                reading = self.ser.readline().decode().strip().split(',')
                #print (reading)
                #comment if not emulator
                listatosend = [float(reading[0])] + [int(i) for i in reading[1:]]
                #listatosend = [(int(reading[0]) - tstart)/1000]+[float(reading[1])]+[int(i) for i  in reading[2:]]
                #print (listatosend)
                self.info.emit(listatosend)
            except:
                pass


    def stopping(self):
        self.stop = True
        self.ser.close()
        self.wait()
        self.quit()
        print('measure stopoped')
    
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
        emulator.stopping()

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
        #monitor channel
        mch = 'ch0'
        #reference channel Cerenkov
        rch = 'ch1'

        #lets find the start and stop of all beams
        dff = pd.DataFrame({'time':dchs[mch].time, mch:dchs[mch].meas})
        #print(dff.head())
        #print (dff.dtypes)
        #print (dff.describe())
        dff['chdiff'] = dff[mch].diff()
        #print(dff.head())
        dffchanges =  dff.loc[dff.chdiff.abs() > 1000, :].copy()
        #print (dffchanges.head())
        dffchanges['timediff'] = dffchanges.time.diff()
        dffchanges.fillna(1, inplace=True)
        dfftimes =  dffchanges[dffchanges.timediff > 0.5].copy()
        #print (dfftimes.head())
        starttimes = dfftimes.loc[dfftimes.chdiff < 0, 'time']
        print (starttimes)
        finishtimes = dfftimes.loc[dfftimes.chdiff > 0, 'time']
        print (finishtimes)

        #Calculate the integrals in each region
        #and update the information in the dqmlchs objects

        for key, ch in dchs.items():
            ch.calcintegral(starttimes, finishtimes)
            dqmlchs[key]._integral = ch.integral
            dqmlchs[key]._listaint = ch.listaint

        #send to qml the limits to plot in chartview
        self.signallimitslists.emit(list(starttimes), list(finishtimes))



#Create the main app
app = QApplication(sys.argv)

#Create a qml object to update qml with teh list of measurements
listain = Listain()

mylimitslines = LimitsLines()

regulateps = RegulatePSThread()

mysubtractdc = SubtractDcThread()

mystopthread = StopThread()
mystopthread.signallimitslists.connect(mylimitslines.limitsin)

#create the channels based in the number of channels
number_of_ch = 8
dchs = {'ch%s' %i : CH(i) for i in range(number_of_ch)}

#create python objects to be ready to push to qml for each channel
dqmlchs = {'ch%s' %i : CHQml() for i in range(number_of_ch)}

#create the qml engine
engine = QQmlApplicationEngine()

#include the listain object as a qml object
engine.rootContext().setContextProperty('listain', listain)

engine.rootContext().setContextProperty('limitslines', mylimitslines)

#push the qmlchs objects to qml file
for i, qmlch in enumerate(dqmlchs.values()):
    engine.rootContext().setContextProperty('qmlch%s' %i, qmlch)

#Load the qml file
engine.load('bluephysics.qml')

#Create the emulator thread
#Comment if not emulator
emulator = EmulatorThread()

#Create the measure thread
measure = MeasureThread()

#info is the signal created with every measurements
#updatea listain qml object to update graphs in qml
measure.info.connect(listain.lista)

#also use the update function to update the python lists
#and then save all measurements in a file
measure.info.connect(update)


#From metadata.csv file create a dic with current metadata
metadatafile = open('metadata.csv', 'r')
listmetadata = [pair.split(',') for pair in metadatafile.readlines()]
metadatakeylist = [key for [key, value] in listmetadata]
metadatafile.close()
dmetadata = {key:value.strip() for [key,value] in listmetadata}


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
    dmetadata['File Name'] = filenamefromqml.property('text')
    filesnow = os.listdir('rawdata')
    if ('%s.csv' %dmetadata['File Name'] in filesnow) and (dmetadata['File Name'] != 'default'):
        filename = dmetadata['File Name']
        samefiles = [f for f in filesnow if f.startswith(filename)]
        #print (samefiles)
        samefilesnumbers = []
        for samefile in samefiles:
            if '-' in samefile:
                pos = samefile.find('-')
                current_num = int(samefile[pos+1:-4])
                samefilesnumbers.append(current_num)

        #print (samefilesnumbers)
        if len(samefilesnumbers) == 0:
            new_name = '%s-2' %filename

        else:
            maxnumb = max(samefilesnumbers)
            newnumb = maxnumb + 1
            new_name = '%s-%s' %(filename, newnumb)


        dmetadata['File Name'] = new_name

    #Start the emulator thread
    #Comment if not emulator
    emulator.start()

    #Start the measurements thread
    measure.start()


#Create an object from qml linked to the start button
startb = engine.rootObjects()[0].findChild(QObject, 'startbutton')
#Now link the start button signal with the qmlstart function in python
startb.clicked.connect(qmlstart)

#Create an object in python from qml linked to the stop button
stopb = engine.rootObjects()[0].findChild(QObject, 'stopbutton')
#Connect the signal click from the stop button in qml
#to the python funcition called qmlstop
stopb.clicked.connect(mystopthread.start)

regulateb = engine.rootObjects()[0].findChild(QObject, 'regulatebutton')
regulateb.clicked.connect(regulateps.start)

psspinbox = engine.rootObjects()[0].findChild(QObject, 'psspinbox')

filenamefromqml = engine.rootObjects()[0].findChild(QObject, 'filename')
print (filenamefromqml)

regulateprogressbar = engine.rootObjects()[0].findChild(QObject, 'regulateprogressbar')

subtractdcb = engine.rootObjects()[0].findChild(QObject, 'subtractdcb')
subtractdcb.clicked.connect(mysubtractdc.start)

sdcprogressbar = engine.rootObjects()[0].findChild(QObject, 'sdcprogressbar')


#Close qml engine if the app is closed
engine.quit.connect(app.quit)
sys.exit(app.exec_())

#!/usr/bin/env python3

from PyQt5 import QtCore
import sys
import os
import time
import pyqtgraph as pg
from PyQt5.QtWidgets import *
from PyQt5.uic import loadUi
from PyQt5.QtCore import QTimer, QThread, pyqtSignal


import serial
       

#Global flag to indicate if there are measurements done
measurements_done = False


def clearLayout(layout):
    for i in reversed(range(layout.count())):
        item = layout.itemAt(i)
        if isinstance(item, QWidgetItem):
            item.widget().setParent(None)
        else:
            layout.removeItem(item)


class EmulatorThread(QThread):
    
    def __init__(self):
        QThread.__init__(self)
        self.stop = False
        self.ser2 = serial.Serial ('/dev/pts/3', 115200, timeout=1)
        file = open('./rawdata/emulatormeasurementsosciloscope.csv', 'r')
        self.lines =  file.readlines()
        file.close()
        
    def __del__(self):
        self.wait()
        
    def run(self):
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


class MeasureThread(QThread):

    info = pyqtSignal (list)

    def __init__(self):
        QThread.__init__(self)
        self.stop = False
        #emulator
        #self.ser = serial.Serial ('/dev/pts/4', 115200, timeout=1)
        self.ser = serial.Serial ('/dev/ttyACM0', 115200, timeout=1)

    def __del__(self):
        self.wait()

    def run(self):
        #One reading to discard garbge
        reading0 = self.ser.readline().decode().strip().split(',')

        #second reading to check starting time
        #comment if emulator
        reading1 = self.ser.readline().decode().strip().split(',')
        tstart = int(reading1[0])
        
        while True:
            
            if self.stop:
                break

            
            reading = self.ser.readline().decode().strip().split(',')
            #print (reading)
            #comment if not emulator
            #listatosend = [float(i) for i in reading]
            listatosend = [(int(reading[0])-tstart)/1000] + [float(reading[1])] + [float(i) for i in reading[2:]]
            #print (listatosend)
            self.info.emit(listatosend)
            #except:
                #pass
  
    def stopping(self):
        self.stop = True
        self.ser.close()
        self.wait()
        self.quit()
                   
       
class MainMenu (QMainWindow):

    def __init__(self):
        QMainWindow.__init__(self)
        loadUi("mainmenuguiosciloscope.ui", self)
        self.mymeasure = Measure()
        self.signals()
        self.setwindowstitle()

    def setwindowstitle(self):
        windowstitle = 'Blue Physics Osciloscope'
        self.setWindowTitle(windowstitle)
        self.mymeasure.setWindowTitle(windowstitle)
       
    def signals(self):
        self.tbmeasure.clicked.connect(self.showmeasure)
        self.tboff.clicked.connect(app.quit)

   
    def showmeasure(self):
        self.close()
        self.mymeasure.show()
        

class Measure(QMainWindow):
    
    def __init__(self):
        QMainWindow.__init__(self)
        loadUi("measureguiosciloscope.ui", self)
        
        self.signals()
        
        #Creat the plot for measuring
        #Source https://htmlcolorcodes.com
        
        
        self.plotitem1 = pg.PlotItem()
        self.plotitem1.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitem1.setLabel('bottom', 'Time', units ='s')
        
        self.plotitem2 = pg.PlotItem()
        self.plotitem2.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitem2.setLabel('bottom', 'Time', units ='s')
        
        self.plotitem3 = pg.PlotItem()
        self.plotitem3.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitem3.setLabel('bottom', 'Time', units ='s')
        
        self.plotitem4 = pg.PlotItem()
        self.plotitem4.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitem4.setLabel('bottom', 'Time', units ='s')
        
        self.plotitem5 = pg.PlotItem()
        self.plotitem5.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitem5.setLabel('bottom', 'Time', units='s')

        
        self.curve1 = self.plotitem1.plot(pen=pg.mkPen(color='#990000', width=1))
        self.curve2 = self.plotitem2.plot(pen=pg.mkPen(color='#009900', width=1))
        self.curve3 = self.plotitem3.plot(pen=pg.mkPen(color='#990099', width=1))
        self.curve4 = self.plotitem4.plot(pen=pg.mkPen(color='#999999', width=1))
        self.curve5 = self.plotitem5.plot(pen=pg.mkPen(color='#000099', width=1))

        
        self.graphicsView.addItem(self.plotitem1,row=0,col=0)
        self.graphicsView.addItem(self.plotitem2,row=0,col=1)
        self.graphicsView.addItem(self.plotitem3,row=1,col=0)
        self.graphicsView.addItem(self.plotitem4,row=1,col=1)
        self.graphicsView.addItem(self.plotitem5,row=2,col=0)

    def signals(self):
        self.tbmainmenu.clicked.connect(self.backmainmenu)
        self.tbstartmeasure.clicked.connect(self.startmeasuringforgood)
        self.tbstopmeasure.clicked.connect(self.stopmeasurement)
                   
            
    def startmeasuringforgood(self):

        #Refresh screen and reset buttons
        #clearLayout (self.graphicsView)
        
        self.time = []
        self.ch1 = []
        self.ch2 = []
        self.ch3 = []
        self.ch4 = []
        self.ch5 = []

        self.ch1tp = []
        self.ch2tp = []
        self.ch3tp = []
        self.ch4tp = []
        self.ch5tp = []

        self.tbstopmeasure.setEnabled(True)
        self.tbstartmeasure.setEnabled(False)

        #only if emulator
        #self.emulator = EmulatorThread()
        #self.emulator.start()
        
        self.measurethread = MeasureThread()
        self.measurethread.start()

        self.measurethread.info.connect(self.update)
        

      
    def update(self, measurements):
        
        self.time.append(measurements[0])
        self.ch1.append(measurements[10])
        self.ch2.append(measurements[11])
        self.ch3.append(measurements[12])
        self.ch4.append(measurements[13])
        self.ch5.append(measurements[1])

        ch1value = measurements[10] * self.ch1_gain.value() * self.ch1_amp.value()
        ch2value = measurements[11] * self.ch2_gain.value() * self.ch2_amp.value()
        ch3value = measurements[12] * self.ch3_gain.value() * self.ch3_amp.value()
        ch4value = measurements[13] * self.ch4_gain.value() * self.ch4_amp.value()
        ch5value = measurements[1]

        self.ch1tp.append(ch1value)
        self.ch2tp.append(ch2value)
        self.ch3tp.append(ch3value)
        self.ch4tp.append(ch4value)
        self.ch5tp.append(ch5value)
  
        
        DS = 1 #Downsampling
        self.curve1.setData(self.time[::DS], self.ch1tp[::DS])
        self.curve2.setData(self.time[::DS], self.ch2tp[::DS])
        self.curve3.setData(self.time[::DS], self.ch3tp[::DS])
        self.curve4.setData(self.time[::DS], self.ch4tp[::DS])
        self.curve5.setData(self.time[::DS], self.ch5tp[::DS])


    def stopmeasurement(self):
        self.measurethread.stopping()
        #emulator
        #self.emulator.stopping()
        self.tbstopmeasure.setEnabled(False)
        self.tbstartmeasure.setEnabled(True)

        
        #Save data in files and close files
        
        self.filemeas = open ('./rawdata/default.csv', 'w')


        self.filemeas.write('time,ch1,ch2,ch3,ch4,ch5\n')
        
        for i in range(len(self.time)):
            self.filemeas.write('%.1f,%.4f,%.7f,%.7f,%.7f,%.7f,\n' %(self.time[i],
                                                                     self.ch1[i],
                                                                     self.ch2[i],
                                                                     self.ch3[i],
                                                                     self.ch4[i],
                                                                     self.ch5[i]))

        self.filemeas.close()



    def backmainmenu(self):
        self.close()
        mymainmenu.show()

    
    
if __name__ == '__main__':
    
    app = QApplication(sys.argv)
    app.setStyle(QStyleFactory.create('Fusion'))
    mymainmenu = MainMenu()
    mymainmenu.show()
    sys.exit(app.exec_())

#!/usr/bin/env python3
#branch master

from PyQt5 import QtCore
import sys
import os
#os.environ["QT_IM_MODULE"] = "qtvirtualkeyboard"
#os.environ["QT_VIRTUALKEYBOARD_STYLE"] = "retro"
#print (os.environ)
import time
import pyqtgraph as pg
import pandas as pd
from PyQt5.QtWidgets import *
from PyQt5.uic import loadUi
from matplotlib.backends.backend_qt5agg import (NavigationToolbar2QT,
                                                FigureCanvas)
from matplotlib.figure import Figure
import matplotlib.pyplot as plt
from PyQt5.QtCore import QTimer, QThread, pyqtSignal, QObject
#from PyQt5.QtQuick import QQuickView
#from PyQt5.QtQml import QQmlApplicationEngine

import atexit

import serial
import serial.tools.list_ports


class CH():

    def __init__(self, num):
        self.num = num
        self.name = 'ch%s' %num
        self.color = colors[num]
        self.time = []
        self.temp = []
        self.meas = []
        self.meastp = []
        self.inttime = int(dmetadata['Integration Time']) * 1e-3
        self.curve = mymainmenu.mymeasure.plotitemchs.plot(pen=pg.mkPen(color=self.color, width=2),
                                              autoDownsample = False)
        self.button = mymainmenu.mymeasure.Layoutbuttons.itemAt(num).widget()
        print (self.name, self.button.text(), self.button)
        self.button.clicked.connect(self.viewplot)



    def update(self):
        self.curve.setData(self.time[::1], self.meastp[::1])

    def viewplot(self):
        if self.button.isChecked():
            mymainmenu.mymeasure.plotitemchs.addItem(self.curve)
            mymainmenu.mymeasure.legend.addItem(self.curve, self.name)
            if measurements_done:
                self.curve.setData(self.df.time, self.df.measVz)
                mymainmenu.mymeasure.plotitemchs.addItem(self.text)
        else:
            mymainmenu.mymeasure.plotitemchs.removeItem(self.curve)
            mymainmenu.mymeasure.legend.removeItem(self.name)
            if measurements_done:
                mymainmenu.mymeasure.plotitemchs.removeItem(self.text)

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
        self.df['measVz'] = self.df.measV - self.df.loc[(self.df.time<(self.ts-2))|(self.df.time>(self.tf+2)), 'measV'].mean()
        #self.df['measz'] = self.df.meas - self.df.loc[self.df.time < 5, 'meas'].mean()
        #calculate integral
        self.integral = self.df.loc[(self.df.time>(self.ts-2))&(self.df.time<(self.tf+2)), 'measVz'].sum()
        #self.integral = self.df.loc[:, 'measz'].sum()
        #put the full plot
        self.text = pg.TextItem('Int: %.2f V' %(self.integral), color = self.color)
        self.text.setPos((self.df.time.max())/2 - 5, self.df.measVz.max())
        #self.viewplot()
        
        #Now we calculate the integrals of each beam and put it in a list
        self.listaint = []
        for (st, ft) in zip(starttimes, finishtimes):
                intbeamn = self.df.loc[(self.df.time>(st-2))&(self.df.time<(ft+2)), 'measVz'].sum()
                self.listaint.append(intbeamn)
        


#Read Metadata file and load data in a dictionary
metadatafile = open('metadata.csv', 'r')
listmetadata = [pair.split(',') for pair in metadatafile.readlines()]
metadatakeylist = [key for [key, value] in listmetadata]
metadatafile.close()
global dmetadata
dmetadata = {key:value.strip() for [key,value] in listmetadata}

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
        self.ser2 = serial.Serial ('/dev/pts/2', 115200, timeout=1)
        file = open('./rawdata/emulatormeasurements.csv', 'r')
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
        #self.ser = serial.Serial ('/dev/pts/3', 115200, timeout=1)
        device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        self.ser = serial.Serial (device, 115200, timeout=1)

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
            
            try:
                reading = self.ser.readline().decode().strip().split(',')
                #print (reading)
                #comment if not emulator
                #listatosend = [int(i) for i in reading]
                listatosend = [(int(reading[0]) - tstart)/1000]+[float(reading[1])]+[int(i) for i  in reading[2:]]
                #print (listatosend) 
                self.info.emit(listatosend)
            except:
                pass

 

            
    def stopping(self):
        self.stop = True
        self.ser.close()
        self.wait()
        self.quit()
        
class IonChamber(QDialog):
    def __init__(self):
        QDialog.__init__(self)
        loadUi("ionchamber.ui", self)
        self.icmeas.setValue(float(dmetadata['IC Measure']))
        self.ictemp.setValue(float(dmetadata['IC Temperature']))
        self.icpressure.setValue(float(dmetadata['IC Pressure']))
        self.icmeasslider.setValue(int(self.icmeas.value()*1000))
        self.ictempslider.setValue(int(self.ictemp.value()*100))
        self.icpressureslider.setValue(int(self.icpressure.value()*10))
        self.icmeas.valueChanged.connect(lambda e: self.icmeasslider.setValue(int(e*1000)))
        self.icmeasslider.valueChanged.connect(lambda e: self.icmeas.setValue(e/1000))
        self.ictemp.valueChanged.connect(lambda e: self.ictempslider.setValue(int(e*100)))
        self.ictempslider.valueChanged.connect(lambda e: self.ictemp.setValue(e/100))
        self.icpressure.valueChanged.connect(lambda e: self.icpressureslider.setValue(int(e*10)))
        self.icpressureslider.valueChanged.connect(lambda e: self.icpressure.setValue(e/10))        
        self.savenext.clicked.connect(self.savenextaction)
        self.cancel.clicked.connect(self.close)
        self.savecurrent.clicked.connect(self.savecurrentaction)
        
    def savecurrentaction(self):
        currentfile = open('rawdata/%s.csv' %dmetadata['File Name'], 'r+')
        currentlines = currentfile.readlines()
        currentlines[22] = 'IC Measure,%s\n' %(self.icmeas.value())
        currentlines[23] = 'IC Temperature,%s\n' %(self.ictemp.value())
        currentlines[24] = 'IC Pressure,%s\n' %(self.icpressure.value())
        currentfile.seek(0)
        currentfile.truncate()
        for line in currentlines:
            currentfile.write(line)
        currentfile.close()
        self.savenextaction()
        
        
        
    def savenextaction(self):
        dmetadata['IC Measure'] = str(self.icmeas.value())
        dmetadata['IC Temperature'] = str(self.ictemp.value())
        dmetadata['IC Pressure'] = str(self.icpressure.value())
        self.close()
        
        
       
class MainMenu (QMainWindow):

    def __init__(self):
        QMainWindow.__init__(self)
        loadUi("mainmenugui.ui", self)
        self.mymeasure = Measure()
        self.mymetadata = Metadata()
        self.metadatadictogui()
        #self.myanalyze = Analyze()
        self.signals()
        self.setwindowstitle()
        #self.test = keyboardapp()
        
        
    def metadatadictogui(self):
        
        if dmetadata['Save File As'] == 'Default':
            self.mymetadata.cbdefault.setChecked(True)
            self.mymetadata.cbcustom.setChecked(False)
            self.mymetadata.lefilename.setText('default')
            self.mymetadata.lefilename.setText(dmetadata['File Name'])
        elif dmetadata['Save File As'] == 'Custom':
            self.mymetadata.cbdefault.setChecked(False)
            self.mymetadata.cbcustom.setChecked(True)
            #self.lefilename.setReadOnly(False)
            self.mymetadata.lefilename.setText(dmetadata['File Name'])
        
        self.mymetadata.sbacr.setValue(float(dmetadata['Adjacent Channels Ratio']))
        self.mymetadata.sbrefcharge.setValue(float(dmetadata['Reference Charge']))
        self.mymetadata.sbcf.setValue(float(dmetadata['Calibration Factor']))
        self.mymetadata.lefacility.setText(dmetadata['Facility'])
        self.mymetadata.leinvestigator.setText(dmetadata['Investigator'])
        self.mymetadata.sbintegrationtime.setValue(int(dmetadata['Integration Time']))
        self.mymetadata.cbopmode.setCurrentText(dmetadata['Operational Mode'])
        self.mymetadata.cbsource.setCurrentText(dmetadata['Source'])
        self.mymetadata.linacbrand.setCurrentText(dmetadata['Brand'])
        self.mymetadata.linacparticles.setCurrentText(dmetadata['Particles'])
        self.mymetadata.linacenergy.setCurrentText(dmetadata['Energy'])
        self.mymetadata.doserate.setValue(int(dmetadata['Dose Rate']))
        self.mymetadata.gantry.setValue(int(dmetadata['Gantry']))
        self.mymetadata.collimator.setValue(int(dmetadata['Collimator']))
        self.mymetadata.couch.setValue(int(dmetadata['Couch']))
        self.mymetadata.x1coord.setValue(float(dmetadata['Field Size X1']))
        self.mymetadata.x2coord.setValue(float(dmetadata['Field Size X2']))
        self.mymetadata.y1coord.setValue(float(dmetadata['Field Size Y1']))
        self.mymetadata.y2coord.setValue(float(dmetadata['Field Size Y2']))
        self.mymetadata.ssdsad.setCurrentText(dmetadata['Setup'])
        self.mymetadata.ssd.setValue(int(dmetadata['Distance']))
        self.mymetadata.mu.setValue(int(dmetadata['MU']))
        self.mymetadata.sensorpositionx.setValue(float(dmetadata['Sensor Position X']))
        self.mymetadata.sensorpositiony.setValue(float(dmetadata['Sensor Position Y']))
        self.mymetadata.sensorpositionz.setValue(float(dmetadata['Sensor Position Z']))
        self.mymetadata.comments.setText(dmetadata['Comments'])


        
    def setwindowstitle(self):
        windowstitle = 'Blue Physics Model 9.2 File: %s' %(dmetadata['File Name'])
        self.setWindowTitle(windowstitle)
        self.mymeasure.setWindowTitle(windowstitle)
        self.mymetadata.setWindowTitle(windowstitle)
        #self.myanalyze.setWindowTitle('Blue Physics Model 9 Analyze File:')
       
    def signals(self):
        self.tbmeasure.clicked.connect(self.showmeasure)
        self.tboff.clicked.connect(app.quit)
        self.tbsettings.clicked.connect(self.showmetadata)
        #self.tbanalyze.clicked.connect(self.showanalyze)
        
    def showanalyze(self):
        self.close()
        self.myanalyze.show()
        
    def showmetadata(self):
        self.close()
        self.mymetadata.show()
        #winmetadata.show()

        
    def showtemp(self):
        self.close()
        self.mytemp.show()
    
    def showvoltage(self):
        self.close()
        self.myvoltage.show()
   
    def showmeasure(self):
        self.close()
        self.mymeasure.show()
        


class Analyze (QMainWindow):

    def __init__(self):
        QMainWindow.__init__(self)
        loadUi("analyzegui.ui", self)
        self.figure = Figure()
        self.canvas = FigureCanvas(self.figure)
        #self.canvas.figure.set_tight_layout(True)
        self.addToolBar(NavigationToolbar2QT(self.canvas, self))
        self.ax1, self.ax2 = self.figure.subplots(2, 1, sharex=True)
        #self.ax1.grid(True)
        #self.ax2.grid(True)
        #self.ax1.legend()
        #self.ax2.legend()
        self.figure.set_tight_layout(True)
        self.ax2.set_xlabel('time (s)')
        self.horizontalLayout.insertWidget(0, self.canvas)
        self.signals()
        self.relfileloaded = False
        self.plot1buttons = [self.tbviewch0, self.tbviewch1]
        
        
    def signals(self):
        self.tbmainmenuanalyze.clicked.connect(self.backtomainmenu)
        self.tbreffile.clicked.connect(self.selectfile)
        self.tbviewch0.clicked.connect(self.plot1)
        self.tbviewch1.clicked.connect(self.plot1)
        self.tbviewraw.clicked.connect(self.plot1)
        self.tbintegral.clicked.connect(self.plot1)
        self.tbtempcorrec.clicked.connect(self.plot1)
        self.tbcalibration.clicked.connect(self.plot1)
        self.cbsecondplot.currentIndexChanged.connect(self.plot2)
        self.tbrelfile.clicked.connect(self.relfile)

    def relfile(self):
        if self.tbrelfile.isChecked():
            #a funciton to load a second relative file to compare
            #with reference file loaded as self.df
            relfilename = QFileDialog.getOpenFileName(self, 'Open file',
                                                      './rawdata')
            self.dfrel = pd.read_csv(relfilename[0], skiprows=34)
            
            #flag to inidcate we have a relative file loaded
            self.relfileloaded = True

            #A routine to calculate the relative time with the reference
            #measurement under self.df
            self.dfrel['ch1reldiff'] = self.dfrel.ch1.diff()
            self.trs = self.dfrel.loc[self.dfrel.ch1reldiff == self.dfrel.ch1reldiff.max(), 'time'].item()
            timediff = self.trs - self.ts
            self.dfrel['newtimerel'] = self.dfrel.time - timediff
            
            #Calculate start and end of radiation
            #Assuming ch1 is where the sensor is and it has the largest differences
            self.trf = self.dfrel.loc[self.dfrel.ch1reldiff == self.dfrel.ch1reldiff.min(), 'time'].item()
             
            #calculate correction to temperature
            self.dfrel['ch0tc'] = self.dfrel.ch0
            self.dfrel['ch1tc'] = self.dfrel.ch1
            self.dfrel.loc[self.dfrel.ch0<6.26, 'ch0tc'] = self.dfrel.ch0 - (-0.012 * self.dfrel.ch0 + 0.075) * (self.dfrel.temp - 26.8)
            self.dfrel.loc[self.dfrel.ch1<6.26, 'ch1tc'] = self.dfrel.ch1 - (-0.012 * self.dfrel.ch1 + 0.075) * (self.dfrel.temp - 26.8)
                
            #calculate the zeros
            #print ('mean zero ch0tc: %.3f' %(self.dfa.loc[(self.dfa.time<ts)|(self.dfa.time>tf), 'ch0tc'].mean()))
            self.dfrel['ch0ztc'] = self.dfrel.ch0tc - self.dfrel.loc[(self.dfrel.time<self.trs)|(self.dfrel.time>self.trf), 'ch0tc'].mean()
            self.dfrel['ch1ztc'] = self.dfrel.ch1tc - self.dfrel.loc[(self.dfrel.time<self.trs)|(self.dfrel.time>self.trf), 'ch1tc'].mean()
            
            self.dfrel['ch0z'] = self.dfrel.ch0 - self.dfrel.loc[(self.dfrel.time<self.trs)|(self.dfrel.time>self.trf), 'ch0'].mean()
            self.dfrel['ch1z'] = self.dfrel.ch1 - self.dfrel.loc[(self.dfrel.time<self.trs)|(self.dfrel.time>self.trf), 'ch1'].mean()
                
            #calculate integrals not corrected
            self.relintch0tc = self.dfrel.loc[(self.dfrel.time>self.trs)&(self.dfrel.time<self.trf), 'ch0ztc'].sum()
            self.relintch1tc = self.dfrel.loc[(self.dfrel.time>self.trs)&(self.dfrel.time<self.trf), 'ch1ztc'].sum()
            
            self.absdosenocalibtcrel = self.relintch1tc - self.relintch0tc
            self.reldosenocalibtcrel = (self.absdosenocalibtcrel / float(dmetadata['Reference diff Voltage'])) * 100 
            
            self.relintch0 = self.dfrel.loc[(self.dfrel.time>self.trs)&(self.dfrel.time<self.trf), 'ch0z'].sum()
            self.relintch1 = self.dfrel.loc[(self.dfrel.time>self.trs)&(self.dfrel.time<self.trf), 'ch1z'].sum()
            
            self.absdosenocalibrel = self.relintch1 - self.relintch0
            self.reldosenocalibrel = (self.absdosenocalibrel / float(dmetadata['Reference diff Voltage'])) * 100
                
            #Calculate ch0 corrected
            self.dfrel['ch0zc'] = self.dfrel.ch0z * float(dmetadata['Calibration Factor'])
            self.dfrel['ch1zc'] = self.dfrel.ch1z
            
            self.dfrel['ch0zctc'] = self.dfrel.ch0ztc * float(dmetadata['Calibration Factor'])
            self.dfrel['ch1zctc'] = self.dfrel.ch1ztc
             
            #Calculate integrals corrected
            self.relintch0c = self.dfrel.loc[(self.dfrel.time>self.trs)&(self.dfrel.time<self.trf), 'ch0zc'].sum()
            self.relintch1c = self.dfrel.loc[(self.dfrel.time>self.trs)&(self.dfrel.time<self.trf), 'ch1zc'].sum()
            
            self.relintch0ctc = self.dfrel.loc[(self.dfrel.time>self.trs)&(self.dfrel.time<self.trf), 'ch0zctc'].sum()
            self.relintch1ctc = self.dfrel.loc[(self.dfrel.time>self.trs)&(self.dfrel.time<self.trf), 'ch1zctc'].sum()
             
            #calculate absolute dose
            self.relrelabsdose = self.relintch1c - self.relintch0c
            
            self.relrelabsdosetc = self.relintch1ctc - self.relintch0ctc
                
            #calculate relative dose
            self.relreldose = (self.relrelabsdose / float(dmetadata['Reference diff Voltage'])) * 100
            
            self.relreldosetc = (self.relrelabsdosetc / float(dmetadata['Reference diff Voltage'])) * 100

            #plot the relative file
            self.plot1()
 
        else:
            self.relfileloaded = False



    def selectfile(self):
        self.tbrelfile.setEnabled(True)
        #self.ax1.clear()
        #self.ax2.clear()
        filename = QFileDialog.getOpenFileName(self, 'Open file',
                                               './rawdata')
        filename_only = filename[0].split('/')[-1]
        self.setWindowTitle('Blue Physics Model 8.2 Analyze File: %s'
                             %filename_only)
        self.dfa = pd.read_csv(filename[0], skiprows=34)
        
        #Calculate start and end of radiation
        #Assuming ch1 is where the sensor is and it has the largest differences
        self.dfa['ch1diff'] = self.dfa.ch1.diff()
        self.ts = self.dfa.loc[self.dfa.ch1diff == self.dfa.ch1diff.max(), 'time'].item()
        self.tf = self.dfa.loc[self.dfa.ch1diff == self.dfa.ch1diff.min(), 'time'].item()
        print ('Start time: %.2f Finish time: %.2f' %(self.ts, self.tf))
        
        #calculate correction to temperature
        self.dfa['ch0tc'] = self.dfa.ch0
        self.dfa['ch1tc'] = self.dfa.ch1
        self.dfa.loc[self.dfa.ch0<6.25, 'ch0tc'] = self.dfa.ch0 - (-0.012 * self.dfa.ch0 + 0.075) * (self.dfa.temp - 26.8)
        self.dfa.loc[self.dfa.ch1<6.25, 'ch1tc'] = self.dfa.ch1 - (-0.012 * self.dfa.ch1 + 0.075) * (self.dfa.temp - 26.8)
        
        #calculate the zeros
        #print ('mean zero ch0tc: %.3f' %(self.dfa.loc[(self.dfa.time<ts)|(self.dfa.time>tf), 'ch0tc'].mean()))
        self.dfa['ch0ztc'] = self.dfa.ch0tc - self.dfa.loc[(self.dfa.time<self.ts)|(self.dfa.time>self.tf), 'ch0tc'].mean()
        self.dfa['ch1ztc'] = self.dfa.ch1tc - self.dfa.loc[(self.dfa.time<self.ts)|(self.dfa.time>self.tf), 'ch1tc'].mean()
        
        self.dfa['ch0z'] = self.dfa.ch0 - self.dfa.loc[(self.dfa.time<self.ts)|(self.dfa.time>self.tf), 'ch0'].mean()
        self.dfa['ch1z'] = self.dfa.ch1 - self.dfa.loc[(self.dfa.time<self.ts)|(self.dfa.time>self.tf), 'ch1'].mean()
        
        #calculate integrals not corrected
        self.intch0tc = self.dfa.loc[(self.dfa.time>self.ts)&(self.dfa.time<self.tf), 'ch0ztc'].sum()
        self.intch1tc = self.dfa.loc[(self.dfa.time>self.ts)&(self.dfa.time<self.tf), 'ch1ztc'].sum()
        
        self.absdosenocalibtc = self.intch1tc - self.intch0tc
        self.reldosenocalibtc = (self.absdosenocalibtc / float(dmetadata['Reference diff Voltage'])) * 100 
        
        self.intch0 = self.dfa.loc[(self.dfa.time>self.ts)&(self.dfa.time<self.tf), 'ch0z'].sum()
        self.intch1 = self.dfa.loc[(self.dfa.time>self.ts)&(self.dfa.time<self.tf), 'ch1z'].sum()
        
        self.absdosenocalib = self.intch1 - self.intch0
        self.reldosenocalib = (self.absdosenocalib / float(dmetadata['Reference diff Voltage'])) * 100
        
        #Calculate ch0 corrected
        self.dfa['ch0zctc'] = self.dfa.ch0ztc * float(dmetadata['Calibration Factor'])
        self.dfa['ch1zctc'] = self.dfa.ch1ztc
        
        self.dfa['ch0zc'] = self.dfa.ch0z * float(dmetadata['Calibration Factor'])
        self.dfa['ch1zc'] = self.dfa.ch1z
        
        #Calculate integrals corrected
        self.intch0ctc = self.dfa.loc[(self.dfa.time>self.ts)&(self.dfa.time<self.tf), 'ch0zctc'].sum()
        self.intch1ctc = self.dfa.loc[(self.dfa.time>self.ts)&(self.dfa.time<self.tf), 'ch1zctc'].sum()
        
        self.intch0c = self.dfa.loc[(self.dfa.time>self.ts)&(self.dfa.time<self.tf), 'ch0zc'].sum()
        self.intch1c = self.dfa.loc[(self.dfa.time>self.ts)&(self.dfa.time<self.tf), 'ch1zc'].sum()
        
        #calculate absolute dose
        self.absdosetc = self.intch1ctc - self.intch0ctc
        
        self.absdose = self.intch1c - self.intch0c
        
        #calculate relative dose
        self.reldosetc = (self.absdosetc / float(dmetadata['Reference diff Voltage'])) * 100
        
        self.reldose = (self.absdose / float(dmetadata['Reference diff Voltage'])) * 100
        
        #Plot the selected file running the current functions
        self.plot1()

        self.tbviewch0.setEnabled(True)
        self.tbviewch1.setEnabled(True)
        self.cbsecondplot.setEnabled(True)
        self.tbviewraw.setEnabled(True)
        self.tbintegral.setEnabled(True)
        self.tbtempcorrec.setEnabled(True)
        self.tbcalibration.setEnabled(True)


    def plot1(self):

        self.ax1.clear()
        self.ax1.grid(True)

        if self.tbviewch0.isChecked():
            if (self.tbviewraw.isChecked() and (not self.tbtempcorrec.isChecked() and not self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch0,
                              color = colors[0], label = 'ch0')
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch0,
                                  color = colors[0], alpha = 0.5, label = 'ch0rel')
            elif (self.tbviewraw.isChecked() and (self.tbtempcorrec.isChecked() and not self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch0tc,
                              color = colors[0], label = 'ch0')
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch0tc,
                                  color = colors[0], alpha = 0.5, label = 'ch0rel')
            elif (self.tbintegral.isChecked() and (not self.tbtempcorrec.isChecked() and not self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch0z,
                              color = colors[0], label = 'ch0')
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch0z,
                                  color = colors[0], alpha = 0.5, label = 'ch0rel')
                coordx = self.dfa.time.max() / 2
                coordy = self.dfa.ch0z.max()
                self.ax1.text(coordx, coordy, 'int: %.2f' %(self.intch0), color=colors[0])
            elif (self.tbintegral.isChecked() and (self.tbtempcorrec.isChecked() and not self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch0ztc,
                              color = colors[0], label = 'ch0')
                coordx = self.dfa.time.max() / 2
                coordy = self.dfa.ch0ztc.max()
                self.ax1.text(coordx, coordy, 'int: %.2f' %(self.intch0tc), color=colors[0])
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch0ztc,
                                  color = colors[0], alpha = 0.5, label = 'ch0rel')
            elif (self.tbintegral.isChecked() and (not self.tbtempcorrec.isChecked() and self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch0zc,
                              color = colors[0], label = 'ch0')
                coordx = self.dfa.time.max() / 2
                coordy = self.dfa.ch0zc.max()
                self.ax1.text(coordx, coordy, 'int: %.2f' %self.intch0c, color=colors[0])
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch0zc,
                                  color = colors[0], alpha = 0.5, label = 'ch0rel')
            elif (self.tbintegral.isChecked() and (self.tbtempcorrec.isChecked() and self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch0zctc,
                              color = colors[0], label = 'ch0')
                coordx = self.dfa.time.max() / 2
                coordy = self.dfa.ch0zctc.max()
                self.ax1.text(coordx, coordy, 'int: %.2f' %self.intch0ctc, color=colors[0])
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch0zctc,
                                  color = colors[0], alpha = 0.5, label = 'ch0rel')

                
        if self.tbviewch1.isChecked():
            if (self.tbviewraw.isChecked() and (not self.tbtempcorrec.isChecked() and not self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch1,
                              color = colors[1], label = 'ch1')
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch1,
                                  color = colors[1], alpha = 0.5, label = 'ch1rel')
            elif (self.tbviewraw.isChecked() and (self.tbtempcorrec.isChecked() and not self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch1tc,
                              color = colors[1], label = 'ch1')
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch1tc,
                                  color = colors[1], alpha = 0.5, label = 'ch1rel')
            elif (self.tbintegral.isChecked() and (not self.tbtempcorrec.isChecked() and not self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch1z,
                              color = colors[1], label = 'ch1')
                coordx = self.dfa.time.max() / 2
                coordy = self.dfa.ch1z.max()
                self.ax1.text(coordx, coordy, 'int: %.2f abs dose: %.2f rel dose: %.2f' %(self.intch1, self.absdosenocalib, self.reldosenocalib), color=colors[1])
                self.ax1.text(coordx, coordy-1, 'int: %.2f abs dose: %.2f rel dose: %.2f' %(self.intch1, self.absdosenocalib, self.reldosenocalib), color=colors[1], alpha=0.5)
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch1z,
                                  color = colors[1], alpha = 0.5, label = 'ch1rel')
            elif (self.tbintegral.isChecked() and (self.tbtempcorrec.isChecked() and not self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch1ztc,
                              color = colors[1], label = 'ch1')
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch1ztc,
                                  color = colors[1], alpha = 0.5, label = 'ch1rel')
                coordx = self.dfa.time.max() / 2
                coordy = self.dfa.ch1ztc.max()
                self.ax1.text(coordx, coordy-1, 'int: %.2f abs dose: %.2f rel dose: %.2f' %(self.relintch1tc, self.absdosenocalibtcrel, self.reldosenocalibtcrel), color=colors[1], alpha=0.5)
                self.ax1.text(coordx, coordy, 'int: %.2f abs dose: %.2f rel dose: %.2f' %(self.intch1tc, self.absdosenocalibtc, self.reldosenocalibtc), color=colors[1])
            elif (self.tbintegral.isChecked() and (not self.tbtempcorrec.isChecked() and self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch1zc,
                              color = colors[1], label = 'ch1')
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch1zc,
                                  color = colors[1], alpha = 0.5, label = 'ch1rel')
                coordx = self.dfa.time.max() / 2
                coordy = self.dfa.ch1zc.max()
                self.ax1.text(coordx, coordy, 'int: %.2f abs dose: %.2f rel dose: %.2f' %(self.intch1c, self.absdose, self.reldose), color=colors[1])
            elif (self.tbintegral.isChecked() and (self.tbtempcorrec.isChecked() and self.tbcalibration.isChecked())):
                self.ax1.plot(self.dfa.time, self.dfa.ch1zctc,
                              color = colors[1], label = 'ch1')
                if self.relfileloaded:
                    self.ax1.plot(self.dfrel.newtimerel, self.dfrel.ch1zctc,
                                  color = colors[1], alpha = 0.5, label = 'ch1rel')
                coordx = self.dfa.time.max() / 2
                coordy = self.dfa.ch1zctc.max()
                self.ax1.text(coordx, coordy, 'int: %.2f abs dose: %.2f rel dose: %.2f' %(self.intch1ctc, self.absdosetc, self.reldosetc), color=colors[1])
                
       
        self.ax1.set_ylabel('volts (V)')
        self.ax1.legend()
        self.canvas.draw()
 
        
        
    def plot2(self, index):
        
        self.ax2.clear()
        self.ax2.set_ylabel('Volts (V)')
        
        if index == 1:
            self.dfa.set_index('time').loc[:,'temp'].plot(ax=self.ax2,
                                                          color='#002525',
                                                          grid=True)

            self.ax2.set_ylabel('Temp (C)')
            if self.relfileloaded:
                self.dfrel.set_index('newtimerel').loc[:,'temp'].plot(ax=self.ax2,
                                                                      color = '#002525',
                                                                      alpha=0.5,
                                                                      grid=True)
        elif index == 2:
            self.dfa.set_index('time').loc[:,'PS'].plot(ax=self.ax2,
                                                        grid=True,
                                                        color='#000099')
            if self.relfileloaded:
                self.dfrel.set_index('newtimerel').loc[:,'PS'].plot(ax=self.ax2,
                                                                    color = '#002525',
                                                                    alpha=0.5,
                                                                    grid=True)

        elif index == 3:
            self.dfa.set_index('time').loc[:,'-12V':'10.58V'].plot(ax=self.ax2, grid=True)
            if self.relfileloaded:
                self.dfrel.set_index('newtimerel').loc[:,'-12V':'10.58V'].plot(ax=self.ax2,
                                                                               alpha=0.5,
                                                                               grid=True)

       

        self.ax2.set_xlabel('time (s)')
        #self.ax2.legend(True)
        self.canvas.draw()
    
    
    def backtomainmenu(self):
        self.close()
        mymainmenu.show()



class Metadata (QMainWindow):
    
    def __init__(self):
        QMainWindow.__init__(self)
        #engine = QQmlApplicationEngine()
        #engine.load('metadataqml.qml')
        loadUi("metadatagui2.ui", self)
        self.signals()
        #self.view = QQuickView()
        #self.view.setObjectName('View')
        #self.view.setSource(QUrl('main.qml'))
        #self.view.setResizeMode(QQuickView.SizeRootObjectToView)
        #teclado.setParent(self.widgetteclado)
        #self.cbsaveoncurrentmeasurements.setChecked(True)
        #self.verticalLayoutgeneral.addItem(itemteclado)
        
        
    def signals(self):
        self.tbgeneral.clicked.connect(self.showgeneralpage)
        self.tblinac.clicked.connect(self.showlinacpage)
        #self.tbsensor.clicked.connect(self.showsensorpage)
        #self.tbcomments.clicked.connect(self.showcommentspage)
        self.tbmainmenumetadata.clicked.connect(self.backtomainmenu)
        self.cbdefault.clicked.connect(self.saveasfilename)
        self.cbcustom.clicked.connect(self.saveasfilename)
        self.cbsaveoncurrentmeasurements.clicked.connect(self.saveoncurrent)
        self.cbsymetric.clicked.connect(self.symetry)
        self.x1coord.valueChanged.connect(self.symx1ch)
        self.x1slider.valueChanged.connect(lambda e: self.x1coord.setValue(e/10))
        self.x2coord.valueChanged.connect(lambda e: self.x2slider.setValue(int(e*10)))
        self.x2slider.valueChanged.connect(lambda e: self.x2coord.setValue(e/10))
        self.y1coord.valueChanged.connect(lambda e: self.y1slider.setValue(int(e*10)))
        self.y1slider.valueChanged.connect(lambda e: self.y1coord.setValue(e/10))
        self.y2coord.valueChanged.connect(lambda e: self.y2slider.setValue(int(e*10)))
        self.y2slider.valueChanged.connect(lambda e: self.y2coord.setValue(e/10))
        self.sbintegrationtime.valueChanged.connect(self.inttimeslider.setValue)
        self.inttimeslider.valueChanged.connect(self.sbintegrationtime.setValue)
        self.sbacr.valueChanged.connect(lambda e: self.acrslider.setValue(int(e*1000)))
        self.acrslider.valueChanged.connect(lambda e: self.sbacr.setValue(e/1000))
        self.sbrefcharge.valueChanged.connect(lambda e: self.refchargeslider.setValue(int(e*1000)))
        self.refchargeslider.valueChanged.connect(lambda e: self.sbrefcharge.setValue(e/1000))
        self.sbcf.valueChanged.connect(lambda e: self.cfslider.setValue(int(e*10000)))
        self.cfslider.valueChanged.connect(lambda e: self.sbcf.setValue(e/10000))
        self.doserate.valueChanged.connect(self.doserateslider.setValue)
        self.doserateslider.valueChanged.connect(self.doserate.setValue)
        self.ssd.valueChanged.connect(self.ssdslider.setValue)
        self.ssdslider.valueChanged.connect(self.ssd.setValue)
        self.mu.valueChanged.connect(self.ssdslider.setValue)
        self.muslider.valueChanged.connect(self.mu.setValue)
        self.sensorpositionx.valueChanged.connect(lambda e: self.sensorpositionxslider.setValue(int(e*100)))
        self.sensorpositionxslider.valueChanged.connect(lambda e: self.sensorpositionx.setValue(e/100))
        self.sensorpositiony.valueChanged.connect(lambda e: self.sensorpositionyslider.setValue(int(e*100)))
        self.sensorpositionyslider.valueChanged.connect(lambda e: self.sensorpositiony.setValue(e/100))
        self.sensorpositionz.valueChanged.connect(lambda e: self.sensorpositionzslider.setValue(int(e*100)))
        self.sensorpositionzslider.valueChanged.connect(lambda e: self.sensorpositionz.setValue(e/100))
        self.gantry.valueChanged.connect(self.gantrydial.setValue)
        self.gantrydial.valueChanged.connect(self.gantry.setValue)
        self.collimator.valueChanged.connect(self.collimatordial.setValue)
        self.collimatordial.valueChanged.connect(self.collimator.setValue)
        self.couch.valueChanged.connect(self.couchdial.setValue)
        self.couchdial.valueChanged.connect(self.couch.setValue)
        self.pbsendtocontroller.clicked.connect(self.sendtocontroller)
        
        
    def sendtocontroller(self):
        device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        self.serc = serial.Serial(device, 115200, timeout=1)
        texttosend = 'c%s,%s' %(self.sbintegrationtime.value(), self.cbopmode.currentText()[0])
        print (texttosend.encode())
        self.serc.write(texttosend.encode())
        self.serc.close()
        
    def symx1ch(self, value):
        self.x1slider.setValue(int(value*10))
        if self.cbsymetric.isChecked():
            self.x2coord.setValue(-value)
            self.x2slider.setValue(int(-value)*10)
            self.y1coord.setValue(value)
            self.y1slider.setValue(int(value)*10)
            self.y2coord.setValue(-value)
            self.y2slider.setValue(int(-value)*10)

    def symetry(self):
        if self.cbsymetric.isChecked():
            self.y1coord.setEnabled(False)
            self.y1slider.setEnabled(False)
            self.x2coord.setEnabled(False)
            self.x2slider.setValue(False)
            self.y2coord.setEnabled(False)
            self.y2slider.setEnabled(False)
        else:
            self.y1coord.setEnabled(True)
            self.y1slider.setEnabled(True)
            self.x2coord.setEnabled(True)
            self.x2slider.setValue(True)
            self.y2coord.setEnabled(True)
            self.y2slider.setEnabled(True)  


    def saveoncurrent(self):
        if self.cbsaveoncurrentmeasurements.isChecked():
            self.lefilename.setReadOnly(True)
        else:
            self.lefilename.setReadOnly(False)
        
    def saveasfilename(self):
        if not(self.cbsaveoncurrentmeasurements.isChecked()):
            if self.cbdefault.isChecked():
                self.lefilename.setText('default')
                self.lefilename.setReadOnly(True)
            elif self.cbcustom.isChecked():
                self.lefilename.setText('')
                self.lefilename.setReadOnly(False)
        
    def metadataguitodic(self):
        if self.cbdefault.isChecked():
            dmetadata['Save File As'] =  'Default'
        if self.cbcustom.isChecked():
            dmetadata['Save File As'] = 'Custom'
        dmetadata['File Name'] = self.lefilename.text()
        dmetadata['Adjacent Channels Ratio'] = str(self.sbacr.value())
        dmetadata['Reference Charge'] = str(self.sbrefcharge.value())
        dmetadata['Calibration Factor'] = str(self.sbcf.value())
        dmetadata['Facility'] = self.lefacility.text()
        dmetadata['Investigator'] = self.leinvestigator.text()
        dmetadata['Integration Time'] = str(self.sbintegrationtime.value())
        dmetadata['Operational Mode'] = str(self.cbopmode.currentText())
        dmetadata['Source'] = self.cbsource.currentText()
        dmetadata['Brand'] = self.linacbrand.currentText()
        dmetadata['Particles'] = self.linacparticles.currentText()
        dmetadata['Energy'] = self.linacenergy.currentText()
        dmetadata['Dose Rate'] = str(self.doserate.value())
        dmetadata['Gantry'] = str(self.gantry.value())
        dmetadata['Collimator'] = str(self.collimator.value())
        dmetadata['Couch'] = str(self.couch.value())
        dmetadata['Field Size X1'] =  str(self.x1coord.value())
        dmetadata['Field Size X2'] =  str(self.x2coord.value())
        dmetadata['Field Size Y1'] =  str(self.y1coord.value())
        dmetadata['Field Size Y2'] =  str(self.y2coord.value())
        dmetadata['Setup'] = self.ssdsad.currentText()
        dmetadata['Distance'] =  str(self.ssd.value())
        dmetadata['MU'] = str(self.mu.value())
        dmetadata['Sensor Position X'] = str(self.sensorpositionx.value())
        dmetadata['Sensor Position Y'] = str(self.sensorpositiony.value())
        dmetadata['Sensor Position Z'] = str(self.sensorpositionz.value())
        dmetadata['Comments'] =  self.comments.toPlainText()
        
    def backtomainmenu(self):
        self.close()
        self.metadataguitodic()
        
        #If there is already a measument done add the changes to the header file
        #First check if there are measurements
        #global measurements_done
        if measurements_done and self.cbsaveoncurrentmeasurements.isChecked():
            #read the current files
            filepow = open('./rawdata/%spowers.csv' %dmetadata['File Name'], 'r')
            filemeas = open('./rawdata/%smeasurements.csv' %dmetadata['File Name'], 'r')
            #read lines
            filepowlines = filepow.readlines()
            filemeaslines = filemeas.readlines()
            filepow.close()
            filemeas.close()
            #find the number of lines of metadata
            nlinesmeta = len(metadatakeylist)
            #Create the new list of lines
            #first add the new metadata
            newfilepowlines = ['%s,%s\n' %(key,dmetadata[key]) for key in metadatakeylist]
            newfilemeaslines = ['%s,%s\n' %(key,dmetadata[key]) for key in metadatakeylist]
            #then add the current measurements
            for line in filepowlines[nlinesmeta:]:
                newfilepowlines.append(line)
            for line in filemeaslines[nlinesmeta:]:
                newfilemeaslines.append(line)
            #Save the new changes and overwrite the old files
            newfilepow = open('./rawdata/%spowers.csv' %dmetadata['File Name'], 'w')
            newfilemeas = open('./rawdata/%smeasurements.csv' %dmetadata['File Name'], 'w')
            newfilepow.writelines(newfilepowlines)
            newfilemeas.writelines(newfilemeaslines)
            newfilepow.close()
            newfilemeas.close()
            
        mymainmenu.setwindowstitle()
        
        mymainmenu.show()
        
    def showcommentspage(self):
        self.swmetadata.setCurrentIndex(3)
        
    def showsensorpage(self):
        self.swmetadata.setCurrentIndex(2)
        
    def showlinacpage(self):
        self.swmetadata.setCurrentIndex(1)
        
    def showgeneralpage(self):
        self.swmetadata.setCurrentIndex(0)


class Measure(QMainWindow):
    
    def __init__(self):
        QMainWindow.__init__(self)
        loadUi("measuregui.ui", self)
        for num in range(8):
            print(self.Layoutbuttons.itemAt(num).widget())
        
        #Creat the plot for measuring
        #Source https://htmlcolorcodes.com
        self.plotitemchs = pg.PlotItem()
        self.plotitemchs.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitemchs.setLabel('bottom', 'Time', units='s')
        self.plotitemchs.setLabel('left', 'Voltage', units='V')
        self.legend = self.plotitemchs.addLegend()
        self.plotitemPS = pg.PlotItem(title= '<span style="color: #000099">PS</span>')
        self.plotitemPS.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitemPS.setLabel('bottom', 'Time', units ='s')
        self.plotitemPS.setLabel('left', 'Voltage', units = 'V')
        self.plotitem5v = pg.PlotItem(title ='<span style="color: #009999">5V</span>')
        self.plotitem5v.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitem5v.setLabel('bottom', 'Time', units = 's')
        self.plotitem5v.setLabel('left', 'Voltage', units = 'V')
        self.plotitemvref = pg.PlotItem(title ='<span style="color: #990000">Vref</span>')
        self.plotitemvref.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitemvref.setLabel('bottom', 'Time', units = 's')
        self.plotitemvref.setLabel('left', 'Voltage', units = 'V')
        self.plotitemminus12v = pg.PlotItem(title ='<span style="color: #990099">-12V</span>')
        self.plotitemminus12v.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitemminus12v.setLabel('bottom', 'Time', units = 's')
        self.plotitemminus12v.setLabel('left', 'Voltage', units = 'V')
        self.plotitemtemp = pg.PlotItem(title = '<span style="color: #002525">Temp C')
        self.plotitemtemp.showGrid(x = True, y = True, alpha = 0.5)
        self.plotitemtemp.setLabel('bottom', 'Time', units = 's')
        self.plotitemtemp.setLabel('left', 'Temperature', units = 'C')
        
        
                
        self.curvePS = self.plotitemPS.plot(pen=pg.mkPen(color='#000099', width=2),
                                                   autoDownsample = False)

        self.curve5V = self.plotitem5v.plot(pen=pg.mkPen(color='#009999',
                                                                          width=2),
                                                  autoDownsample = False)
        self.curveminus12V = self.plotitemminus12v.plot(pen=pg.mkPen(color='#990099',
                                                                 width=2),
                                                  autoDownsample = False)
        self.curverefV = self.plotitemvref.plot(pen=pg.mkPen(color='#990000',
                                                                        width=2),
                                                   autoDownsample = False)


        self.curvetemp = self.plotitemtemp.plot(pen=pg.mkPen(color='#002525', width=2),
                                                   autoDownsample = False)
        
        self.signals()
        
        self.graphicsView.addItem(self.plotitemchs)
        #self.viewplots()
        self.inttime = int(dmetadata['Integration Time']) * 1e-3

       
    def signals(self):
        self.tbmainmenu.clicked.connect(self.backmainmenu)
        self.tbstartmeasure.clicked.connect(self.startmeasuring)
        self.cbsecondplot.currentIndexChanged.connect(self.secondplot)
        self.tbstopmeasure.clicked.connect(self.stopmeasurement)
        self.tbdarkcurrent.clicked.connect(self.rmdarkcurrent)
        self.PowerSupply.clicked.connect(self.powersupply)
        self.ionchamber.clicked.connect(self.ionchamberaction)
        self.tbregulate.clicked.connect(self.regulate)
        
    def regulate(self):
        self.tbstartmeasure.setEnabled(False)
        device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        self.serreg = serial.Serial(device, 115200, timeout=1)
        self.serreg.write(('r%.2f,' %self.sbvoltage.value()).encode())
        print (('r%.2f,' %self.sbvoltage.value()).encode())
        line = self.serreg.readline().decode().strip().split(',')
        for i in range(20):
            line = self.serreg.readline().decode().strip().split(',')
            print (line)
        while len(line) == 10:
            line = self.serreg.readline().decode().strip().split(',')
            print (line)
        self.serreg.close()
        self.tbstartmeasure.setEnabled(True)
        
    def ionchamberaction(self):
        self.ionchamberwindow = IonChamber()
        self.ionchamberwindow.show()
        
    def powersupply(self):
        device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        self.serp = serial.Serial(device, 115200, timeout=1)
        if self.PowerSupply.isChecked():
            texttosend = 'w1'
            self.serp.write(texttosend.encode())
            print (texttosend.encode())
        else:
            texttosend = 'w0'
            self.serp.write(texttosend.encode())
            print (texttosend.encode())
        self.serp.close()


    def rmdarkcurrent(self):
        self.tbstartmeasure.setEnabled(False)
        device = list(serial.tools.list_ports.grep('Adafruit ItsyBitsy M4'))[0].device
        self.ser = serial.Serial(device, 115200, timeout=1)
        self.ser.write('s'.encode())
        for i in range(20):
            line = self.ser.readline().decode().strip().split(',')
            print (line)
        while len(line) == 9:
            print(line)
            line = self.ser.readline().decode().strip().split(',')
        self.ser.close()
        self.tbstartmeasure.setEnabled(True)
        


    def secondplot(self, index):
        #clearLayout(self.gridmeasure)
        #self.gridmeasure.addWidget(self.plotitemchs)
        itemtoremove = self.graphicsView.getItem(1, 0)
        if itemtoremove:
            self.graphicsView.removeItem(itemtoremove)
        if index == 1:
            self.graphicsView.addItem(self.plotitemtemp,row=1,col=0)
        elif index == 2:
            self.graphicsView.addItem(self.plotitemPS, row=1, col=0)
        elif index == 3:
            self.graphicsView.addItem(self.plotitem5v, row=1, col=0)
        elif index == 4:
            self.graphicsView.addItem(self.plotitemvref, row=1, col=0)
        elif index == 5:
            self.graphicsView.addItem(self.plotitemminus12v, row=1, col=0)


    def startmeasuring(self):
        #Check if the file already exist, to prevent overwritting
        filesnow = os.listdir('rawdata')
        if ('%s.csv' %dmetadata['File Name'] in filesnow) and (dmetadata['File Name'] != 'default'):
            filename = dmetadata['File Name']
            #check if file names ends with -num
            if '-' in filename:
                pos = filename.find('-')
                current_num = int(filename[pos+1:])
                new_num = current_num + 1
                new_name = '%s-%s' %(filename[:pos], new_num)
                
            else:
                new_name = '%s-2' %filename
                
            buttonreply = QMessageBox.question(self, 'File exists',
                                  "Change to %s?" %new_name,
                                  QMessageBox.Yes | QMessageBox.No, QMessageBox.Yes)
                                  
            if buttonreply == QMessageBox.Yes:
                dmetadata['File Name'] = new_name
                mymainmenu.setwindowstitle()
                self.startmeasuringforgood()
            else:
                self.close()
                mymainmenu.mymetadata.show()
        else:
            self.startmeasuringforgood()
                   
            
    def startmeasuringforgood(self):

        #Refresh screen and reset buttons
        #clearLayout (self.gridmeasure)
        global measurements_done
        measurements_done = False
        
        self.plotitemchs.clear()
        #self.viewplots()
        self.legend.scene().removeItem(self.legend)
        self.legend = self.plotitemchs.addLegend()
        for ch in dchs.values():
            ch.time = []
            ch.temp = []
            ch.meas = []
            ch.meastp = []
        self.time = []
        self.PSmeas = []
        self.PSmeastp = []
        self.minus12Vmeas = []
        self.minus12Vmeastp = []
        self.v5Vmeas = []
        self.v5Vmeastp = []
        self.vrefVmeas = []
        self.vrefVmeastp = []


        self.tbstopmeasure.setEnabled(True)
        self.tbstartmeasure.setEnabled(False)
        self.tbdarkcurrent.setEnabled(False)
        self.PowerSupply.setEnabled(False)
        self.tbregulate.setEnabled(False)
        
        if dmetadata['Save File As'] == 'Date/Time':
            dmetadata['File Name'] = time.strftime ('%d %b %Y %H:%M:%S')
            
        dmetadata['Date Time'] = time.strftime('%d %b %Y %H:%M:%S')

        #only if emulator
        #self.emulator = EmulatorThread()
        #self.emulator.start()
        
        self.measurethread = MeasureThread()
        self.measurethread.start()
        for ch in dchs.values():
            ch.viewplot()
        self.measurethread.info.connect(self.update)
        

      
    def update(self, meas):
        #print (measurements)
        for ch in dchs.values():
            ch.time.append(meas[0])
            ch.temp.append(meas[1])
            ch.meas.append(meas[ch.num+2])
            ch.meastp.append(-meas[ch.num+2] * 20.48 / 65535 + 10.24)
        self.time.append(meas[0])
        self.PSmeas.append(meas[len(dchs)+3])
        self.PSmeastp.append(meas[len(dchs)+3]*0.1875*16.341/1000)
        self.minus12Vmeas.append(meas[len(dchs)+4])
        self.minus12Vmeastp.append(meas[len(dchs)+4]*0.1875*-2.6470/1000)
        self.v5Vmeas.append(meas[len(dchs)+2])
        self.v5Vmeastp.append(meas[len(dchs)+2]*0.1875/1000)
        self.vrefVmeas.append(meas[len(dchs)+5])
        self.vrefVmeastp.append(meas[len(dchs)+5]*0.0625/1000)   
        
        DS = 1 #Downsampling
        self.curvetemp.setData(self.time[::DS], dchs['ch0'].temp[::DS])
        for ch in dchs.values():
            ch.update()
        self.curve5V.setData(self.time[::DS], self.v5Vmeastp[::DS])
        self.curverefV.setData(self.time[::DS], self.vrefVmeastp[::DS])
        self.curveminus12V.setData(self.time[::DS], self.minus12Vmeastp[::DS])
        self.curvePS.setData(self.time[::DS], self.PSmeastp[::DS])


    def stopmeasurement(self):
        self.measurethread.stopping()
        #emulator
        #self.emulator.stopping()
        self.tbstopmeasure.setEnabled(False)
        self.tbstartmeasure.setEnabled(True)
        self.tbdarkcurrent.setEnabled(True)
        self.PowerSupply.setEnabled(True)
        self.tbregulate.setEnabled(True)
        
        #Global flag idicating measurements are done
        global measurements_done
        measurements_done = True
        
        #Save data in files and close files
        
        self.filemeas = open ('./rawdata/%s.csv' %dmetadata['File Name'], 'w')

        for key in metadatakeylist:
            self.filemeas.write('%s,%s\n' %(key,dmetadata[key]))

        self.filemeas.write('time,temp,%s,PS,-12V,5V,refV\n' %','.join([ch for ch in sorted(dchs)]))
        for i in range(len(self.time)):
            line1 = '%s,%.4f' %(self.time[i], dchs['ch0'].temp[i])
            line2 = ','.join(['%s' %dchs[ch].meas[i] for ch in sorted(dchs)])
            line3 = '%s,%s,%s,%s' %(self.PSmeas[i], self.minus12Vmeas[i], self.v5Vmeas[i], self.vrefVmeas[i])
            self.filemeas.write('%s,%s,%s\n' %(line1, line2, line3))

        self.filemeas.close()
        self.plotitemchs.clear()
        self.legend.scene().removeItem(self.legend)
        self.legend = self.plotitemchs.addLegend()
        
        
        #monitor channel
        self.mch = 'ch0'
        #reference channel Cerenkov
        self.rch = 'ch1'
        
        #lets find the start and stop of all beams
        dff = pd.DataFrame({'time':dchs[self.mch].time, self.mch:dchs[self.mch].meas})
        #print(dff.head())
        #print (dff.dtypes)
        #print (dff.describe())
        dff['chdiff'] = dff[self.mch].diff()
        #print(dff.head())
        dffchanges =  dff.loc[dff.chdiff.abs() > 1000, :].copy()
        #print (dffchanges.head())
        dffchanges['timediff'] = dffchanges.time.diff()
        dffchanges.fillna(1, inplace=True)
        dfftimes =  dffchanges[dffchanges.timediff > 0.5].copy()
        #print (dfftimes.head())
        starttimes = dfftimes.loc[dfftimes.chdiff < 0, 'time']
        #print (starttimes)
        finishtimes = dfftimes.loc[dfftimes.chdiff > 0, 'time']
        #print (finishtimes)
        
        self.linearregions = []
        for (st, ft) in zip(starttimes, finishtimes):
            self.linearregions.append(pg.LinearRegionItem(values=(st-2, ft+2), movable=False))
            
        for lr in self.linearregions:
                self.plotitemchs.addItem(lr)
                
        self.plotitemchs.scene().sigMouseMoved.connect(self.mouseMoved)
        
        for ch in dchs.values():
            ch.calcintegral(starttimes, finishtimes)
            
        dchs[self.mch].chargedose = dchs[self.mch].integral - dchs[self.rch].integral * float(dmetadata['Adjacent Channels Ratio'])
        dchs[self.mch].reldose = dchs[self.mch].chargedose/float(dmetadata['Reference Charge']) * 100
        dchs[self.mch].dose = dchs[self.mch].chargedose * float(dmetadata['Calibration Factor'])
        dchs[self.mch].listachargedoses = [i - j * float(dmetadata['Adjacent Channels Ratio']) for (i, j) in zip(dchs[self.mch].listaint, dchs[self.rch].listaint)]
        dchs[self.mch].listareldoses = [i/float(dmetadata['Reference Charge'])*100 for i in dchs[self.mch].listachargedoses]
        dchs[self.mch].listadoses = [i * float(dmetadata['Calibration Factor']) for i in dchs[self.mch].listachargedoses]
        dchs[self.rch].text.setText('Total Volt.: %.2f V'%(dchs[self.rch].integral))
        #dchs[self.mch].text.setText('Total Volt.: %.2f V Charge~dose: %.2f V\n'
         #                           'Rel.dose: %.2f %% Abs.dose: %.2f cGy'%(dchs[self.mch].integral,
          #                                                                dchs[self.mch].chargedose,
           #                                                               dchs[self.mch].reldose,
            #                                                              dchs[self.mch].dose))
        
        
        
        for ch in dchs.values():
            ch.viewplot()
            
    def mouseMoved(self, evt):
        listaindex = [lr.sceneBoundingRect().contains(evt) for lr in self.linearregions]
        if (sum(listaindex)) > 0:
            #find the index where the True value is
            gi = listaindex.index(True)
            dchs[self.rch].text.setText('Charge: %.2f nC'%(dchs[self.rch].listaint[gi]))
            #dchs[self.mch].text.setText('Charge: %.2f nC Charge~dose: %.2f nC\n'
             #                           'Rel.dose: %.2f %% Abs.dose: %.2f cGy'%(dchs[self.mch].listaint[gi],
              #                                                                dchs[self.mch].listachargedoses[gi],
               #                                                               dchs[self.mch].listareldoses[gi],
                #                                                              dchs[self.mch].listadoses[gi]))
                
        else:
            dchs[self.rch].text.setText('Charge: %.2f nC'%(dchs[self.rch].integral))
            #dchs[self.mch].text.setText('Charge: %.2f nC Charge~dose: %.2f nC\n'
             #                           'Rel.dose: %.2f %% Abs.dose: %.2f cGy'%(dchs[self.mch].integral,
              #                                                               dchs[self.mch].chargedose,
               #                                                              dchs[self.mch].reldose,
                #                                                             dchs[self.mch].dose))


    def backmainmenu(self):
        self.close()
        mymainmenu.show()


def goodbye():
    print ('bye')
    metadatafile = open('metadata.csv', 'w')
    for key in metadatakeylist:
        metadatafile.write('%s,%s\n' %(key, dmetadata[key]))
        print ('%s,%s\n' %(key, dmetadata[key]))
    metadatafile.close()
    #mymainmenu.mymeasure.measurepowerthread.stopping()
    
    
if __name__ == '__main__':
    
    app = QApplication(sys.argv)
    #test = keyboardapp()
    #engine = QQmlApplicationEngine()
    #engine.load('main.qml')
    #engine = QQmlApplicationEngine()
    #engine.load('metadataqml.qml')
    #winmetadata = engine.rootObjects()[0]
    #print (type(itemteclado))
    #teclado = winteclado.findChild(QObject, 'virtualkeyword')
    #winteclado.show()
    #app.setStyle(QStyleFactory.create('Fusion'))
    mymainmenu = MainMenu()
    number_of_ch = 8
    colors = ['#ff8000', '#ff0000',
              '#01dfa5', '#cb4335',
              '#884EA0', '#0000ff',
              '#848484', '#000000']
    dchs = {'ch%s' %i : CH(i) for i in range(number_of_ch)}
    atexit.register(goodbye)
    mymainmenu.show()
    sys.exit(app.exec_())

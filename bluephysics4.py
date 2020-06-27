#branch guitoqml

#from PyQt5 import QtCore
import sys
#os.environ["QT_IM_MODULE"] = "qtvirtualkeyboard"
#os.environ["QT_VIRTUALKEYBOARD_STYLE"] = "retro"
#print (os.environ)
from PyQt5.QtWidgets import *
from PyQt5.QtCore import QThread, pyqtSignal, QObject, pyqtSlot, pyqtProperty
from PyQt5.QtQml import QQmlApplicationEngine
import time
import serial
import serial.tools.list_ports

class Listain(QObject):
    signaldatain = pyqtSignal(list, arguments=['lista'])

    def __init__(self, parent=None):
        super().__init__(parent)

    @pyqtSlot(list)
    def lista(self, l):
        self.signaldatain.emit(l)


class EmulatorThread(QThread):
    
    def __init__(self):
        QThread.__init__(self)
        
    def __del__(self):
        self.wait()
        
    def run(self):
        self.stop = False
        file = open('./rawdata/emulatormeasurements.csv', 'r')
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
    


app = QApplication(sys.argv)
listain = Listain()
engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty('listain', listain)
engine.load('main.qml')
emulator = EmulatorThread()
measure = MeasureThread()
measure.info.connect(listain.lista)

def qmlstart():
    emulator.start()
    measure.start()


def qmlstop():
    emulator.stopping()
    measure.stopping()

startb = engine.rootObjects()[0].findChild(QObject, 'startbutton')
stopb = engine.rootObjects()[0].findChild(QObject, 'stopbutton')
stopb.clicked.connect(qmlstop)
startb.clicked.connect(qmlstart)
engine.quit.connect(app.quit)
sys.exit(app.exec_())

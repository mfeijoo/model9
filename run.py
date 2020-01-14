from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import QObject
import sys
import os

os.environ["QT_IM_MODULE"] = "qtvirtualkeyboard"


app = QApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.load('metadataqml.qml')
winmetadata = engine.rootObjects()[0]
mytext = winmetadata.findChild(QObject, 'mytext')
print (mytext.property('text'))
sys.exit(app.exec_())

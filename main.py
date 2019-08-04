import board
import busio
import digitalio
import time
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn

#Time since last integral started
tsli = time.monotonic()

#set time for integral in ns
integraltime = 0.150

#Define testpin
testpin = digitalio.DigitalInOut(board.D7)
testpin.direction = digitalio.Direction.OUTPUT
testpin.value = False

#Define reset pin using A2
resetpin = digitalio.DigitalInOut(board.A2)
resetpin.direction = digitalio.Direction.OUTPUT
resetpin.value = True

#Define hold pin using A3
holdpin = digitalio.DigitalInOut(board.A3)
holdpin.direction = digitalio.Direction.OUTPUT
holdpin.value = False

#Creating i2c bus
i2c = busio.I2C(board.SCL, board.SDA)

#Generating chip in ADS1115 as ads on bus i2c
ads = ADS.ADS1115(i2c)
ads.gain = 2/3

#Measurements from ADS1115
PS0 = AnalogIn(ads, ADS.P0)
Vminus12 = AnalogIn(ads, ADS.P1)
V5 = AnalogIn(ads, ADS.P2)
V1058 = AnalogIn(ads, ADS.P3)

#Put all 8 TCA's ports as output
while not i2c.try_lock():
    pass

#Put i2cMutex pointing to ch3
i2c.writeto(0x74, bytes([0b00001000]))

#Put TCA's as output
i2c.writeto(0x38, bytes([0x03, 0x00]))

#Activate PS using ch0 of TCA
#i2c.writeto(0x38, bytes([0x01, 0b00000001]))

#Deactivate PS
i2c.writeto(0x38, bytes([0x01, 0b00000000]))

#Setting voltages to eliminaate dark current
value = int(65535/2) #any value between 0 and 65535
i2c.writeto(0xf, bytes([0x10, value>>8, value&0xFF]))
i2c.writeto(0xf, bytes([0x11, value>>8, value&0xFF]))
i2c.writeto(0xf, bytes([0x12, value>>8, value&0xFF]))
i2c.writeto(0xf, bytes([0x13, value>>8, value&0xFF]))
i2c.writeto(0xf, bytes([0x14, value>>8, value&0xFF]))
i2c.writeto(0xf, bytes([0x15, value>>8, value&0xFF]))
i2c.writeto(0xf, bytes([0x16, value>>8, value&0xFF]))
i2c.writeto(0xf, bytes([0x17, value>>8, value&0xFF]))

i2c.unlock()

#Turn down A0 as address of CS
ADCdireccion = digitalio.DigitalInOut(board.A0)
ADCdireccion.direction = digitalio.Direction.OUTPUT
ADCdireccion.value = False

#Defining ADC CS in pin A1
ADCcs = digitalio.DigitalInOut(board.A1)
ADCcs.direction = digitalio.Direction.OUTPUT
ADCcs.value = True

#Defining Pot CS
potcs = digitalio.DigitalInOut(board.D2)
potcs.direction = digitalio.Direction.OUTPUT
potcs.value = True

#Integrator or pulses
#A4 True integrador, False pulses
integratorpulses = digitalio.DigitalInOut(board.A4)
integratorpulses.direction = digitalio.Direction.OUTPUT
integratorpulses.value = True #set as integrator
#integratorpulses.value = False #set for pulses

#Creating SPI bus
spi = busio.SPI(board.SCK, MOSI=board.MOSI, MISO=board.MISO)

#Setting the pot for the first time
while not spi.try_lock():
    pass

spi.configure(baudrate=5000000, phase=1, polarity=0)

potcs.value = False
spi.write(bytes([0x1c, 0x03]))
potcs.value = True
potcount = 1023  #any value between 0 and 1023
potcs.value = False
spi.write(bytes([(0x400 | potcount) >> 8, (0x400 | potcount) & 0xff]))
potcs.value = True
spi.unlock()

print ('pot set at: %s' %potcount)

#Lock SPI bus
while not spi.try_lock():
    pass

#Configure SPI bus
spi.configure(baudrate=17000000, phase=1, polarity=0)

#Set range ch0 +-2.5 * Vref
ADCcs.value = False
spi.write(bytes([0x05<<1|1, 0x00, 0x00]))
ADCcs.value = True

#Set range ch1 +-2.5 * Vref (4.096V)
ADCcs.value = False
spi.write(bytes([0x06<<1|1, 0x00, 0x00]))
ADCcs.value = True

#Set range ch2 +-2.5 * Vref
ADCcs.value = False
spi.write(bytes([0x07<<1|1, 0x00, 0x00]))
ADCcs.value = True

#Set range ch3 +-2.5 * Vref
ADCcs.value = False
spi.write(bytes([0x08<<1|1, 0x00, 0x00]))
ADCcs.value = True

#Set range ch4 +-2.5 * Vref
ADCcs.value = False
spi.write(bytes([0x09<<1|1, 0x00, 0x00]))
ADCcs.value = True

#Set range ch5 +-2.5 * Vref
ADCcs.value = False
spi.write(bytes([0x0A<<1|1, 0x00, 0x00]))
ADCcs.value = True

#Set range ch6 +-2.5 * Vref
ADCcs.value = False
spi.write(bytes([0x0B<<1|1, 0x00, 0x00]))
ADCcs.value = True

#Set range ch7 +-2.5 * Vref
ADCcs.value = False
spi.write(bytes([0x0C<<1|1, 0x00, 0x00]))
ADCcs.value = True

ch0b = bytearray(2)
ch1b = bytearray(2)
ch2b = bytearray(2)
ch3b = bytearray(2)
ch4b = bytearray(2)
ch5b = bytearray(2)
ch6b = bytearray(2)
ch7b = bytearray(2)

#Initiate auto reset to collect all channels
ADCcs.value = False
spi.write(bytes([0xA0, 0x00]))
spi.write(bytes([0x00, 0x00]))
ADCcs.value = True

#set UART port
uart = busio.UART(board.TX, board.RX, baudrate=115200)


while True:


    #check if time integration has passed
    if time.monotonic() > (tsli + integraltime):

        testpin.value = True

        #Hold and measure
        holdpin.value = True

        ADCcs.value = False
        spi.write(bytes([0x00, 0x00]))
        spi.write_readinto(bytes([0x00, 0x00]), ch0b)
        ADCcs.value = True

        ADCcs.value = False
        spi.write(bytes([0x00, 0x00]))
        spi.write_readinto(bytes([0x00, 0x00]), ch1b)
        ADCcs.value = True

        ADCcs.value = False
        spi.write(bytes([0x00, 0x00]))
        spi.write_readinto(bytes([0x00, 0x00]), ch2b)
        ADCcs.value = True

        ADCcs.value = False
        spi.write(bytes([0x00, 0x00]))
        spi.write_readinto(bytes([0x00, 0x00]), ch3b)
        ADCcs.value = True

        ADCcs.value = False
        spi.write(bytes([0x00, 0x00]))
        spi.write_readinto(bytes([0x00, 0x00]), ch4b)
        ADCcs.value = True

        ADCcs.value = False
        spi.write(bytes([0x00, 0x00]))
        spi.write_readinto(bytes([0x00, 0x00]), ch5b)
        ADCcs.value = True

        ADCcs.value = False
        spi.write(bytes([0x00, 0x00]))
        spi.write_readinto(bytes([0x00, 0x00]), ch6b)
        ADCcs.value = True

        ADCcs.value = False
        spi.write(bytes([0x00, 0x00]))
        spi.write_readinto(bytes([0x00, 0x00]), ch7b)
        ADCcs.value = True

        testpin.value = False

        #end hold
        holdpin.value = False

        #reset integration, new integration starts
        #tbeforerest = time.monotonic_ns()
        resetpin.value = False
        #while time.monotonic_ns()<(tbeforerest + 500000):
         #   pass
        time.sleep(0.0005)
        resetpin.value = True

        testpin.value = True

        #start next integration
        tsli = time.monotonic()

        lrb = [ch0b, ch1b, ch2b, ch3b, ch4b, ch5b, ch6b, ch7b]

        lrV = ['%.4f' %(-(20.48/65535) * ((i[0]<<8)|(i[1]&0xFF)) + 10.24) for i in lrb]


        uart.write (b'%.3f,%.4f,%.4f,%.4f,%.4f,%s\r\n'
                %(time.monotonic(), PS0.voltage*12.922, Vminus12.voltage * 2.519, V5.voltage,
                V1058.voltage * 2.196, ','.join(lrV)))

        testpin.value = False
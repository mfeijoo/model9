
#include <SPI.h>
#include <Wire.h>
#include "Adafruit_MCP9808.h"
//#include <Adafruit_ADS1015.h>

Adafruit_MCP9808 tempsensor = Adafruit_MCP9808();
//Adafruit_ADS1115 ads;

int ch0b;
int ch1b;
int ch2b;
int ch3b;
int ch4b;
int ch5b;
int ch6b;
int ch7b;
float ch0v;
float ch1v;
float ch2v;
float ch3v;
float ch4v;
float ch5v;
float ch6v;
float ch7v;
float PSV;
float minus12V;
float V5;
float V1058;
int integral = 300;
int regtime = 233;
unsigned long previousMillis = 0;
unsigned long previousregMillis = 0;
int resettime = 500;
int potcount; //pot value in counts from 0 to 1023
float setvolt = 57;
//unsigned char i=0;
//unsigned char j;
//float arrayvolts[]={57.128, 57.128, 57.128, 57.128, 57.128, 57.128, 57.128, 57.128, 57.128, 57.128};
//float sumvolts = 0.0000;
//float avgvolt = 0.0000;
float temp = 27;
int16_t dcvch0 = 65535;
int16_t dcvch1 = 65535;
int16_t dcvch2 = 65535;
int16_t dcvch3 = 65535;
int16_t dcvch4 = 65535;
int16_t dcvch5 = 65535;
int16_t dcvch6 = 65535;
int16_t dcvch7 = 65535;

void setup() {

  Serial1.begin (115200);
  Wire.begin();
  SPI.begin();
  //ads.begin();

  //Address of CS A0 turn it down
  pinMode (A0, OUTPUT);
  digitalWrite (A0, LOW);

  //CS
  pinMode (A1, OUTPUT);
  digitalWrite (A1, HIGH);
  
  //RESET
  pinMode (A2, OUTPUT);
  digitalWrite (A2, HIGH);
  
  //HOLD
  pinMode (A3, OUTPUT);
  digitalWrite (A3, LOW);
  
  //POT
  pinMode (2, OUTPUT);
  digitalWrite (2, HIGH);
  
  //test pin
  pinMode (7, OUTPUT);
  digitalWrite (7, LOW);

  //Put all TCA's ports as output
  Wire.beginTransmission(0x38);
  Wire.write(0x03);
  Wire.write(0x00);
  Wire.endTransmission();

  //Activate PS using ch0 of TCA
  Wire.beginTransmission(0x38);
  Wire.write(0x01);
  Wire.write(0x01);
  //Wire.write(0x00); //to deactivate
  Wire.endTransmission();

  //Put i2cMutex pointing to ch3
  Wire.beginTransmission(0x74);
  Wire.write(0b00001000);
  Wire.endTransmission();

  //Setting voltages to eliminate darkcurrents
  Wire.beginTransmission(0xf);
  Wire.write(0x10);
  Wire.write(dcvch0>>8);
  Wire.write(dcvch0&0xFF);
  Wire.endTransmission();
  Wire.write(0x11);
  Wire.write(dcvch1>>8);
  Wire.write(dcvch1&0xFF);
  Wire.endTransmission();
  Wire.write(0x12);
  Wire.write(dcvch2>>8);
  Wire.write(dcvch2&0xFF);
  Wire.endTransmission();
  Wire.write(0x13);
  Wire.write(dcvch3>>8);
  Wire.write(dcvch3&0xFF);
  Wire.endTransmission();
  Wire.write(0x14);
  Wire.write(dcvch4>>8);
  Wire.write(dcvch4&0xFF);
  Wire.endTransmission();
  Wire.write(0x15);
  Wire.write(dcvch5>>8);
  Wire.write(dcvch5&0xFF);
  Wire.endTransmission();
  Wire.write(0x16);
  Wire.write(dcvch6>>8);
  Wire.write(dcvch6&0xFF);
  Wire.endTransmission();
  Wire.write(0x17);
  Wire.write(dcvch7>>8);
  Wire.write(dcvch7&0xFF);
  Wire.endTransmission();
  
  tempsensor.begin(0x18); //this line on
  tempsensor.setResolution(3); //this line on
  // Mode Resolution SampleTime
  //  0    0.5°C       30 ms
  //  1    0.25°C      65 ms
  //  2    0.125°C     130 ms
  //  3    0.0625°C    250 ms
  tempsensor.wake(); //this line on
  
  //Setting the POT for the first time
  potcount = (int)(((4253.16/(setvolt - 10.58)) - 84.5)*102.3);
  //potcount = 0;
  SPI.beginTransaction(SPISettings(50000000, MSBFIRST, SPI_MODE1));
  //Remove protection from the potentiometer
  digitalWrite(2, LOW);
  SPI.transfer16(0x1c03);
  digitalWrite(2, HIGH);
  //set the pot for the first time
  digitalWrite (2, LOW);
  SPI.transfer16( 0x400 | potcount);
  digitalWrite (2, HIGH);
  SPI.endTransaction();

  //Set range of all channels to +-2.5 * Vref
  SPI.beginTransaction(SPISettings(17000000, MSBFIRST, SPI_MODE1));
  //ch0
  digitalWrite(A1, LOW);
  SPI.transfer(0x05<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A1, HIGH);
  //ch1
  digitalWrite(A1, LOW);
  SPI.transfer(0x06<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A1, HIGH);
  //ch2
  digitalWrite(A1, LOW);
  SPI.transfer(0x07<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A1, HIGH);
  //ch3
  digitalWrite(A1, LOW);
  SPI.transfer(0x08<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A1, HIGH);
  //ch4
  digitalWrite(A1, LOW);
  SPI.transfer(0x09<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A1, HIGH);
  //ch5
  digitalWrite(A1, LOW);
  SPI.transfer(0x0A<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A1, HIGH);
  //ch6
  digitalWrite(A1, LOW);
  SPI.transfer(0x0B<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A1, HIGH);
  //ch7
  digitalWrite(A1, LOW);
  SPI.transfer(0x0C<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A1, HIGH);

  //initiate auto reset to collect all channels
  digitalWrite(A1, LOW);
  SPI.transfer16(0xA000);
  SPI.transfer16(0x0000);
  digitalWrite(A1, HIGH);
  
}

void loop() {

  
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= integral){

      //digitalWrite(7, HIGH);
      
      //hold starts
      digitalWrite(A3, HIGH);

      digitalWrite (A1, LOW);
      SPI.transfer16 (0x0000);
      ch0b = SPI.transfer16 (0x0000);
      digitalWrite (A1, HIGH);
      digitalWrite (A1, LOW);
      SPI.transfer16 (0x0000);
      ch1b = SPI.transfer16 (0x0000);
      digitalWrite (A1, HIGH);
      digitalWrite (A1, LOW);
      SPI.transfer16 (0x0000);
      ch2b = SPI.transfer16 (0x0000);
      digitalWrite (A1, HIGH);
      digitalWrite (A1, LOW);
      SPI.transfer16 (0x0000);
      ch3b = SPI.transfer16 (0x0000);
      digitalWrite (A1, HIGH);
      digitalWrite (A1, LOW);
      SPI.transfer16 (0x0000);
      ch3b = SPI.transfer16 (0x0000);
      digitalWrite (A1, HIGH);
      digitalWrite (A1, LOW);
      SPI.transfer16 (0x0000);
      ch4b = SPI.transfer16 (0x0000);
      digitalWrite (A1, HIGH);
      digitalWrite (A1, LOW);
      SPI.transfer16 (0x0000);
      ch5b = SPI.transfer16 (0x0000);
      digitalWrite (A1, HIGH);
      digitalWrite (A1, LOW);
      SPI.transfer16 (0x0000);
      ch6b = SPI.transfer16 (0x0000);
      digitalWrite (A1, HIGH);
      digitalWrite (A1, LOW);
      SPI.transfer16 (0x0000);
      ch7b = SPI.transfer16 (0x0000);
      digitalWrite (A1, HIGH);
      
      //Hold ends
      digitalWrite (A3, LOW);

      //digitalWrite (7, LOW);

      //reset the integration and a new integration process starts
      digitalWrite (A2, LOW);
      delayMicroseconds (resettime);
      digitalWrite (A2, HIGH);
      previousMillis = millis();

      digitalWrite (7, HIGH);

      //while integration is happening
      //we collect the rest of the CDA power values
      //collect the temperature and send everything via serial

      int16_t adc0, adc1, adc2, adc3;

      Wire.beginTransmission(0x48);
      Wire.write(0b00000001);
      Wire.write(0b01000000);
      Wire.write(0b11100010);
      Wire.endTransmission();
      Wire.beginTransmission(0x48);
      Wire.write(0b00000000);
      Wire.endTransmission();
      delay(4);
      Wire.requestFrom(0x48, 2);
      adc0 = (Wire.read()<<8|Wire.read());
      
      Wire.beginTransmission(0x48);
      Wire.write(0b00000001);
      Wire.write(0b01010000);
      Wire.write(0b11100010);
      Wire.endTransmission();
      Wire.beginTransmission(0x48);
      Wire.write(0b00000000);
      Wire.endTransmission();
      delay(3);
      Wire.requestFrom(0x48, 2);
      adc1 = (Wire.read()<<8|Wire.read());
      
      Wire.beginTransmission(0x48);
      Wire.write(0b00000001);
      Wire.write(0b01100000);
      Wire.write(0b11100010);
      Wire.endTransmission();
      Wire.beginTransmission(0x48);
      Wire.write(0b00000000);
      Wire.endTransmission();
      delay(3);
      Wire.requestFrom(0x48, 2);
      adc2 = (Wire.read()<<8|Wire.read());
      
      Wire.beginTransmission(0x48);
      Wire.write(0b00000001);
      Wire.write(0b01110000);
      Wire.write(0b11100010);
      Wire.endTransmission();
      Wire.beginTransmission(0x48);
      Wire.write(0b00000000);
      Wire.endTransmission();
      delay(3);
      Wire.requestFrom(0x48, 2);
      adc3 = (Wire.read()<<8|Wire.read());

      
      /*adc0 = ads.readADC_SingleEnded(0);
      adc1 = ads.readADC_SingleEnded(1);
      adc2 = ads.readADC_SingleEnded(2);
      adc3 = ads.readADC_SingleEnded(3);*/

      //tempsensor.wake();
      temp = tempsensor.readTempC(); //onlythis line
      //tempsensor.shutdown_wake(1);

      ch0v = -(ch0b * 20.48/65535) + 10.24;
      ch1v = -(ch1b * 20.48/65535) + 10.24;
      ch2v = -(ch2b * 20.48/65535) + 10.24;
      ch3v = -(ch3b * 20.48/65535) + 10.24;
      ch4v = -(ch4b * 20.48/65535) + 10.24;
      ch5v = -(ch5b * 20.48/65535) + 10.24;
      ch6v = -(ch6b * 20.48/65535) + 10.24;
      ch7v = -(ch7b * 20.48/65535) + 10.24;
  
      PSV = adc0 * 0.187 / 1000 * 12.922;
      minus12V = adc1 * 0.187 / 1000 * 2.519;
      V5 = adc2 * 0.187 / 1000;
      V1058 = adc3 * 0.187 / 1000 * 2.196;

      //Include last 10 voltage measurements in an array
      //to calculate average later
      //arrayvolts[i] = PSV;
      //i = i == 9 ? 0 : i + 1;

      //Calculate the average voltage of last 5 measurements
      //sumvolts = 0;
      //for (j = 0; j<10; j++){
        //sumvolts += arrayvolts[j];
     // }

      //avgvolt = sumvolts/10;*/
      
      Serial1.print(previousMillis);
      Serial1.print(",");
      Serial1.print(temp, 4);
      Serial1.print(",");
      Serial1.print(ch0v, 4);
      Serial1.print(",");
      Serial1.print(ch1v, 4);
      Serial1.print(",");
      Serial1.print(ch2v, 4);
      Serial1.print(",");
      Serial1.print(ch3v, 4);
      Serial1.print(",");
      Serial1.print(ch4v, 4);
      Serial1.print(",");
      Serial1.print(ch5v, 4);
      Serial1.print(",");
      Serial1.print(ch6v, 4);
      Serial1.print(",");
      Serial1.print(ch7v, 4);
      Serial1.print(",");
      Serial1.print(PSV);
      Serial1.print(",");
      Serial1.print(minus12V, 4);
      Serial1.print(",");
      Serial1.print(V5, 4);
      Serial1.print(",");
      Serial1.println(V1058, 4);

      digitalWrite(7, LOW);
  }

  /*if (currentMillis - previousregMillis >= regtime){

    //Regulate
      //voltage is too high
      if ((PSV > (setvolt + 0.01)) and (potcount < 1023)){
          potcount = potcount + 1;
          SPI.beginTransaction(SPISettings(50000000, MSBFIRST, SPI_MODE1));
          digitalWrite (pinpot, LOW);
          SPI.transfer16( 0x400 | potcount);
          digitalWrite (pinpot, HIGH);
          SPI.endTransaction();
          }
      //voltage is too low
      else if ((PSV < (setvolt - 0.01)) and (potcount > 0)){
          potcount = potcount - 1;
          SPI.beginTransaction(SPISettings(50000000, MSBFIRST, SPI_MODE1));
          digitalWrite (pinpot, LOW);
          SPI.transfer16( 0x400 | potcount);
          digitalWrite (pinpot, HIGH);
          SPI.endTransaction();
          }

        previousregMillis = millis();
    
  }*/
}

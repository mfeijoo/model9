 
#include <SPI.h>
#include <Wire.h>
#include "Adafruit_MCP9808.h"
//#include <Adafruit_ADS1015.h>

Adafruit_MCP9808 tempsensor = Adafruit_MCP9808();
//Adafruit_ADS1115 ads;

//Ads 1115
//I2C
//A0 -12 Voltios
//A1  PSO
//A2 voltaje del DAC hamamatsu para leer lo que sale del DAC
//A3 5 V
//Direccion en ground

//new adqusition board
//A1 input analogo
//CS conversor analogo digital A4

//Itsibitsy
//A1 hold tarjeta de adquisicion
//A2 switch integrador operaciona
//A3 Reset
//A2 CS SPI
//A5 Shutdown power supply 1 encendido

//empollar AD5693R
//I2C
//conversor de un solo canal
//DAC
//Parecido al de restar corriente
//Ganancia max 2.5 Voltios
//Direccion esta en ground


int16_t ch0b = 0;
int16_t ch1b = 0;
int16_t ch2b = 0;
int16_t ch3b = 0;
int16_t ch4b = 0;
int16_t ch5b = 0;
int16_t ch6b = 0;
int16_t ch7b = 0;
//float ch0v;
//float ch1v;
//float ch2v;
//float ch3v;
//float ch4v;
//float ch5v;
//float ch6v;
//float ch7v;
int16_t adc0;
int16_t adc1;
int16_t adc2;
int16_t adc3;
float PSV;
//float minus12V;
//float V5;
//float VDAC;
int CSnp = 7;
//int newpotcount = 512;
//float V1058;
int integral = 300;
//int regtime = 233;
unsigned long previousMillis = 0;
//unsigned long previousregMillis = 0;
int resettime = 70;
//int potcount; //pot value in counts from 0 to 1023
int potlow;
int pothigh;
int potnow = 512;
float setvolt = 56;
//unsigned char i=0;
//unsigned char j;
//float arrayvolts[]={57.128, 57.128, 57.128, 57.128, 57.128, 57.128, 57.128, 57.128, 57.128, 57.128};
//float sumvolts = 0.0000;
//float avgvolt = 0.0000;
float temp = 27;

//setting voltage for Power Supply
//2.5 Volts = 65535 counts
int16_t dacPS = 26738; 

//5 volts = 65535 counts
//int16_t dcvch0 = 30000;
//int16_t dcvch1 = 20000;
//int16_t dcvch2 = 60000;
//int16_t dcvch3 = 30000;
//int16_t dcvch4 = 50000;
//int16_t dcvch5 = 30000;
//int16_t dcvch6 = 40000;
//int16_t dcvch7 = 30000;

int16_t dcvch0high = 65535;
int16_t dcvch0low = 0;
int16_t dcvch1high = 65535;
int16_t dcvch1low = 0;
int16_t dcvch2high = 65535;
int16_t dcvch2low = 0;
int16_t dcvch3high = 65535;
int16_t dcvch3low = 0;
int16_t dcvch4high = 65535;
int16_t dcvch4low = 0;
int16_t dcvch5high = 65535;
int16_t dcvch5low = 0;
int16_t dcvch6high = 65535;
int16_t dcvch6low = 0;
int16_t dcvch7high = 65535;
int16_t dcvch7low = 0;
int16_t dcvch0 = 0;
int16_t dcvch1 = 0;
int16_t dcvch2 = 0;
int16_t dcvch3 = 0;
int16_t dcvch4 = 0;
int16_t dcvch5 = 0;
int16_t dcvch6 = 0;
int16_t dcvch7 = 0;



void setup(){

  //fan
  //pinMode (12, OUTPUT);
  
  Serial.begin (115200);
  //Serial.println("Hola");
  Wire.begin();
  SPI.begin();
  //ads.begin();

  //Connect the Power Supply
  //HIGH is connected
  pinMode (A5, OUTPUT);
  digitalWrite (A5, LOW);

  delay(2000);
  digitalWrite (A5, HIGH);

  //CStarjeta
  pinMode (A4, OUTPUT);
  digitalWrite (A4, HIGH);
  
  //RESET
  pinMode (10, OUTPUT);
  digitalWrite (10, HIGH);
  
  //HOLD
  pinMode (9, OUTPUT);
  digitalWrite (9, LOW);

  //Integradorpulsos
  pinMode (A0, OUTPUT);
  //HIGH for integrator
  //LOW for pulses
  digitalWrite (A0, HIGH);

  //newPOT
  pinMode(CSnp, OUTPUT);
  digitalWrite(CSnp, HIGH);
  
  //test pin
  //pinMode (7, OUTPUT);
  //digitalWrite (7, LOW);

  //dogwatcher
  pinMode(13, OUTPUT);

  //Setting voltage

  //Settting voltage for power supply with AD5693R
  //By default the gain is set to 0V to 2.5V
  //dacPS at 65535 means 2.5 V
  //By default the Refernce is enabled
  //when in ground I2C Address is 0b1001100
  //then a bit 0 to write
  //0b1001100 = 0x4c
  //Wire.beginTransmission(0x4c);
  //write DAC and input register 0b00110000 = 0x30
  //Wire.write(0x30);
  //send the two bytes of data
  //Wire.write(dacPS>>8);
  //Wire.write(dacPS&0xFF);
  //end transmission
  //Wire.endTransmission();
  
  //Setting voltages to eliminate darkcurrents
  Wire.beginTransmission(0xf);
  Wire.write(0x10);
  Wire.write(dcvch0>>8);
  Wire.write(dcvch0&0xFF);
  Wire.endTransmission();
  Wire.beginTransmission(0xf);
  Wire.write(0x11);
  Wire.write(dcvch1>>8);
  Wire.write(dcvch1&0xFF);
  Wire.endTransmission();
  Wire.beginTransmission(0xf);
  Wire.write(0x12);
  Wire.write(dcvch2>>8);
  Wire.write(dcvch2&0xFF);
  Wire.endTransmission();
  Wire.beginTransmission(0xf);
  Wire.write(0x13);
  Wire.write(dcvch3>>8);
  Wire.write(dcvch3&0xFF);
  Wire.endTransmission();
  Wire.beginTransmission(0xf);
  Wire.write(0x14);
  Wire.write(dcvch4>>8);
  Wire.write(dcvch4&0xFF);
  Wire.endTransmission();
  Wire.beginTransmission(0xf);
  Wire.write(0x15);
  Wire.write(dcvch5>>8);
  Wire.write(dcvch5&0xFF);
  Wire.endTransmission();
  Wire.beginTransmission(0xf);
  Wire.write(0x16);
  Wire.write(dcvch6>>8);
  Wire.write(dcvch6&0xFF);
  Wire.endTransmission();
  Wire.beginTransmission(0xf);
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
  
  //Settting the newPOT for the first time
  //newpotcount = (int)(((4020/(setvolt - 10)) - 80)*102.3);
  //newpotcount = 400;
  SPI.beginTransaction(SPISettings(50000000, MSBFIRST, SPI_MODE1));
  //Remove protection from the new potentiometer
  digitalWrite(CSnp, LOW);
  SPI.transfer16(0x1c02);
  digitalWrite(CSnp, HIGH);
  regulatePS();



  //Set range of all channels to +-2.5 * Vref
  SPI.beginTransaction(SPISettings(17000000, MSBFIRST, SPI_MODE1));
  //ch0
  digitalWrite(A4, LOW);
  SPI.transfer(0x05<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A4, HIGH);
  //ch1
  digitalWrite(A4, LOW);
  SPI.transfer(0x06<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A4, HIGH);
  //ch2
  digitalWrite(A4, LOW);
  SPI.transfer(0x07<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A4, HIGH);
  //ch3
  digitalWrite(A4, LOW);
  SPI.transfer(0x08<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A4, HIGH);
  //ch4
  digitalWrite(A4, LOW);
  SPI.transfer(0x09<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A4, HIGH);
  //ch5
  digitalWrite(A4, LOW);
  SPI.transfer(0x0A<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A4, HIGH);
  //ch6
  digitalWrite(A4, LOW);
  SPI.transfer(0x0B<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A4, HIGH);
  //ch7
  digitalWrite(A4, LOW);
  SPI.transfer(0x0C<<1|1);
  SPI.transfer16(0x0000);
  digitalWrite(A4, HIGH);
  
}

void loop() {


  //fan
  //min 200 0 is maximum
  //analogWrite(12, 150);
  //Serial.println("Hola2");
  
  unsigned long currentMillis = millis();
  
  if (currentMillis - previousMillis >= integral){

      //digitalWrite(7, HIGH);
      //dogwatcher
      digitalWrite(13, HIGH);
      
      //hold starts
      digitalWrite(9, HIGH);

      ReadChannels();
      
      //Hold ends
      digitalWrite (9, LOW);

      //digitalWrite (7, LOW);

      //reset the integration and a new integration process starts
      digitalWrite (10, LOW);
      delayMicroseconds (resettime);
      digitalWrite (10, HIGH);
      previousMillis = millis();

      //digitalWrite (7, HIGH);

      //while integration is happening
      //we collect the rest of the CDA power values
      //collect the temperature and send everything via serial

      Wire.beginTransmission(0x48);
      Wire.write(0b00000001);
      Wire.write(0b01000000);
      Wire.write(0b11100010);
      Wire.endTransmission();
      Wire.beginTransmission(0x48);
      Wire.write(0b00000000);
      Wire.endTransmission();
      delay(5);
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
      delay(5);
      Wire.requestFrom(0x48, 2);
      adc1 = (Wire.read()<<8|Wire.read());
      
      Wire.beginTransmission(0x48);
      Wire.write(0b00000001);
      Wire.write(0b01100100);
      Wire.write(0b11100010);
      Wire.endTransmission();
      Wire.beginTransmission(0x48);
      Wire.write(0b00000000);
      Wire.endTransmission();
      delay(5);
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
      delay(5);
      Wire.requestFrom(0x48, 2);
      adc3 = (Wire.read()<<8|Wire.read());

      
      /*adc0 = ads.readADC_SingleEnded(0);
      adc1 = ads.readADC_SingleEnded(1);
      adc2 = ads.readADC_SingleEnded(2);
      adc3 = ads.readADC_SingleEnded(3);*/

      //tempsensor.wake();
      temp = tempsensor.readTempC(); //onlythis line
      //tempsensor.shutdown_wake(1);

  
      //minus12V = adc0 * 0.1875 / 1000 * 2.6470;
      //PSV = adc1 * 0.1875 / 1000;
      //VDAC = adc2 * 0.1875 / 1000;
      //VDAC = adc2 * 0.0625 / 1000;
      //V5 = adc3 * 0.1875 / 1000;

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

      //ch0v = -(ch0b * 20.48/65535) + 10.24;
      //ch1v = -(ch1b * 20.48/65535) + 10.24;
      //ch2v = -(ch2b * 20.48/65535) + 10.24;
      //ch3v = -(ch3b * 20.48/65535) + 10.24;
      //ch4v = -(ch4b * 20.48/65535) + 10.24;
      //ch5v = -(ch5b * 20.48/65535) + 10.24;
      //ch6v = -(ch6b * 20.48/65535) + 10.24;
      //ch7v = -(ch7b * 20.48/65535) + 10.24;
      
      Serial.print(currentMillis);
      Serial.print(",");
      Serial.print(temp, 4);
      Serial.print(",");
      Serial.print(ch0b);
      Serial.print(",");
      Serial.print(ch1b);
      Serial.print(",");
      Serial.print(ch2b);
      Serial.print(",");
      Serial.print(ch3b);
      Serial.print(",");
      Serial.print(ch4b);
      Serial.print(",");
      Serial.print(ch5b);
      Serial.print(",");
      Serial.print(ch6b);
      Serial.print(",");
      Serial.print(ch7b);
      Serial.print(",");
      Serial.print(adc0);
      Serial.print(",");
      Serial.print(adc1);
      Serial.print(",");
      Serial.print(adc2);
      Serial.print(",");
      Serial.println(adc3);

      //digitalWrite(7, LOW);
      //dogwatcher
      digitalWrite(13, LOW);

  }

    if (Serial.available()>0){
        char inChar = (char)Serial.read();
        if (inChar == 'r'){
          regulatePS();
          
        }
        if (inChar == 's') {
                
        
                while (ch0b < 32700 or
                       ch0b > 32838 or
                       ch1b < 32700 or
                       ch1b > 32838 or
                       ch2b < 32700 or
                       ch2b > 32838 or
                       ch3b < 32700 or
                       ch3b > 32838 or
                       ch4b < 32700 or
                       ch4b > 32838 or
                       ch5b < 32700 or
                       ch5b > 32838 or
                       ch6b < 32700 or
                       ch6b > 32838 or
                       ch7b < 32700 or
                       ch7b > 32838)
                       {
                           if (millis() - previousMillis >= integral){
                                ReadChannelsOnce();
                                if (ch0b < 32700){
                                     dcvch0low = dcvch0;
                                     }
                                 if (ch0b > 32838){
                                     dcvch0high = dcvch0;
                                     }
                                  if (ch1b < 32700){
                                      dcvch1low = dcvch1;
                                      }
                                  if (ch1b > 32838){
                                      dcvch1high = dcvch1;
                                       }
                                   if (ch2b < 32700){
                                     dcvch2low = dcvch2;
                                     }
                                   if (ch2b > 32838){
                                     dcvch2high = dcvch2;
                                     }
                                   if (ch3b < 32700){
                                     dcvch3low = dcvch3;
                                     }
                                 if (ch3b > 32838){
                                     dcvch3high = dcvch3;
                                     }
                                    if (ch4b < 32700){
                                     dcvch4low = dcvch4;
                                     }
                                 if (ch4b > 32838){
                                     dcvch4high = dcvch4;
                                     }
                                    if (ch5b < 32700){
                                     dcvch5low = dcvch5;
                                     }
                                 if (ch5b > 32838){
                                     dcvch5high = dcvch5;
                                     }
                                    if (ch6b < 32700){
                                     dcvch6low = dcvch6;
                                     }
                                 if (ch6b > 32838){
                                     dcvch6high = dcvch6;
                                     }
                                    if (ch7b < 32700){
                                     dcvch7low = dcvch7;
                                     }
                                 if (ch7b > 32838){
                                     dcvch7high = dcvch7;
                                     }
                                   dcvch0 = (dcvch0high + dcvch0low)/2;
                                   dcvch1 = (dcvch1high + dcvch1low)/2;
                                   dcvch2 = (dcvch2high + dcvch2low)/2;
                                   dcvch3 = (dcvch3high + dcvch3low)/2;
                                   dcvch4 = (dcvch4high + dcvch4low)/2;
                                   dcvch5 = (dcvch5high + dcvch5low)/2;
                                   dcvch6 = (dcvch6high + dcvch6low)/2;
                                   dcvch7 = (dcvch7high + dcvch7low)/2;
                                   setvoltdcch0();
                                   setvoltdcch1();
                                   setvoltdcch2();
                                   setvoltdcch3();
                                   setvoltdcch4();
                                   setvoltdcch5();
                                   setvoltdcch6();
                                   setvoltdcch7();
                                   Serial.print("dcvch0,");
                                   Serial.print(dcvch0);
                                   Serial.print(",");
                                   Serial.print("ch0b,");
                                   Serial.println(ch0b);
                                   Serial.print("dcvch1,");
                                   Serial.print(dcvch1);
                                   Serial.print(",");
                                   Serial.print("ch1b,");
                                   Serial.println(ch1b);
                                   Serial.print("dcvch2,");
                                   Serial.print(dcvch2);
                                   Serial.print(",");
                                   Serial.print("ch2b,");
                                   Serial.println(ch2b);
                                   Serial.print("dcvch3,");
                                   Serial.print(dcvch3);
                                   Serial.print(",");
                                   Serial.print("ch3b,");
                                   Serial.println(ch3b);
                                   Serial.print("dcvch4,");
                                   Serial.print(dcvch4);
                                   Serial.print(",");
                                   Serial.print("ch4b,");
                                   Serial.println(ch4b);
                                   Serial.print("dcvch5,");
                                   Serial.print(dcvch5);
                                   Serial.print(",");
                                   Serial.print("ch5b,");
                                   Serial.println(ch5b);
                                   Serial.print("dcvch6,");
                                   Serial.print(dcvch6);
                                   Serial.print(",");
                                   Serial.print("ch6b,");
                                   Serial.println(ch6b);
                                   Serial.print("dcvch7,");
                                   Serial.print(dcvch7);
                                   Serial.print(",");
                                   Serial.print("ch7b,");
                                   Serial.println(ch7b);
                                
                      }
                       }
        }
            if (inChar == 'c'){
                String intts = Serial.readStringUntil(',');
                char pulsint = (char)Serial.read();
                //Serial.println(intts.toInt());
                //Serial.println(pulsint);
                integral = intts.toInt();
                if (pulsint == 'I'){
                       //HIGH for integrator
                       digitalWrite (A4, HIGH);
                        }
                 if (pulsint == 'P'){
                        //LOW for pulses
                        digitalWrite (A4, LOW); 
                        }
            }
            if (inChar == 'w'){
               char ps = (char)Serial.read();
               if (ps == '1'){
                    //Activate PS using ch0 of TCA
                    Wire.beginTransmission(0x38);
                    Wire.write(0x01);
                    Wire.write(0x01); //toactivate
                    //Wire.write(0x00); //to deactivate
                    Wire.endTransmission();
                    }
                if (ps == '0'){
                    //Activate PS using ch0 of TCA
                    Wire.beginTransmission(0x38);
                    Wire.write(0x01);
                    //Wire.write(0x01); //to activate
                    Wire.write(0x00); //to deactivate
                    Wire.endTransmission();
                    }             
               }               
  }      
 }


void ReadChannels(){
  
        SPI.beginTransaction(SPISettings(17000000, MSBFIRST, SPI_MODE1));
        //initiate ch0 manual transfer
        //and read previous set ch7
        digitalWrite(A4, LOW);
        SPI.transfer16(0xC000);
        ch7b = SPI.transfer16(0x0000);
        digitalWrite(A4, HIGH);
        //initiate ch1 manual transfer
        //and read previous set ch0
        digitalWrite (A4, LOW);
        SPI.transfer16 (0xC400);
        ch0b = SPI.transfer16 (0x0000);
        digitalWrite (A4, HIGH);
        //initiate ch2 manual transfer
        //and read previous set ch1
        digitalWrite (A4, LOW);
        SPI.transfer16 (0xC800);
        ch1b = SPI.transfer16 (0x0000);
        digitalWrite (A4, HIGH);
        //initiate ch3 manual transfer
        //and read previous set ch2
        digitalWrite (A4, LOW);
        SPI.transfer16 (0xCC00);
        ch2b = SPI.transfer16 (0x0000);
        digitalWrite (A4, HIGH);
        //initiate ch4 manual transfer
        //and read previous set ch3
        digitalWrite (A4, LOW);
        SPI.transfer16 (0xD000);
        ch3b = SPI.transfer16 (0x0000);
        digitalWrite (A4, HIGH);
        //initiate ch5 manual transfer
        //and read previous set ch4
        digitalWrite (A4, LOW);
        SPI.transfer16 (0xD400);
        ch4b = SPI.transfer16 (0x0000);
        digitalWrite (A4, HIGH);
        //initiate ch6 manual transfer
        //and read previous set ch5
        digitalWrite (A4, LOW);
        SPI.transfer16 (0xD800);
        ch5b = SPI.transfer16 (0x0000);
        digitalWrite (A4, HIGH);
        //initiate ch7 manual transfer
        //and read previous set ch6
        digitalWrite (A4, LOW);
        SPI.transfer16 (0xDC00);
        ch6b = SPI.transfer16 (0x0000);
        digitalWrite (A4, HIGH);

        SPI.endTransaction();

        
        //ch0v = -(ch0b * 20.48/65535) + 10.24;
        //ch1v = -(ch1b * 20.48/65535) + 10.24;
        //ch2v = -(ch2b * 20.48/65535) + 10.24;
        //ch3v = -(ch3b * 20.48/65535) + 10.24;
        //ch4v = -(ch4b * 20.48/65535) + 10.24;
        //ch5v = -(ch5b * 20.48/65535) + 10.24;
        //ch6v = -(ch6b * 20.48/65535) + 10.24;
        //ch7v = -(ch7b * 20.48/65535) + 10.24;
}

void ReadChannelsOnce(){
  //digitalWrite(7, HIGH);
  //hold starts
  digitalWrite(A3, HIGH);
  ReadChannels();
  //Hold ends
  digitalWrite (A3, LOW);
  //digitalWrite (7, LOW);
  //reset the integration and a new integration process starts
  digitalWrite (A2, LOW);
  delayMicroseconds (resettime);
  digitalWrite (A2, HIGH);
  previousMillis = millis();
  //digitalWrite (7, HIGH);
}

void setvoltdcch0(){
  Wire.beginTransmission(0xf);
  Wire.write(0x10);
  Wire.write(dcvch0>>8);
  Wire.write(dcvch0&0xFF);
  Wire.endTransmission();
}

void setvoltdcch1(){
  Wire.beginTransmission(0xf);
  Wire.write(0x11);
  Wire.write(dcvch1>>8);
  Wire.write(dcvch1&0xFF);
  Wire.endTransmission();
}

void setvoltdcch2(){
  Wire.beginTransmission(0xf);
  Wire.write(0x12);
  Wire.write(dcvch2>>8);
  Wire.write(dcvch2&0xFF);
  Wire.endTransmission();
}

void setvoltdcch3(){
  Wire.beginTransmission(0xf);
  Wire.write(0x13);
  Wire.write(dcvch3>>8);
  Wire.write(dcvch3&0xFF);
  Wire.endTransmission();
}

void setvoltdcch4(){
  Wire.beginTransmission(0xf);
  Wire.write(0x14);
  Wire.write(dcvch4>>8);
  Wire.write(dcvch4&0xFF);
  Wire.endTransmission();
}

void setvoltdcch5(){
  Wire.beginTransmission(0xf);
  Wire.write(0x15);
  Wire.write(dcvch5>>8);
  Wire.write(dcvch5&0xFF);
  Wire.endTransmission();
}

void setvoltdcch6(){
  Wire.beginTransmission(0xf);
  Wire.write(0x16);
  Wire.write(dcvch6>>8);
  Wire.write(dcvch6&0xFF);
  Wire.endTransmission();
}
  
void setvoltdcch7(){
  Wire.beginTransmission(0xf);
  Wire.write(0x17);
  Wire.write(dcvch7>>8);
  Wire.write(dcvch7&0xFF);
  Wire.endTransmission(); 
}

void regulatePS(){
  //measure PS once
  potlow = 0;
  pothigh = 1023;
  potnow = 512;
  setpot(potnow);
  readPS();
  

  while (PSV > (setvolt + 0.005) or PSV < (setvolt - 0.005)){  
      //strip.setPixelColor(0, 0, 127, 255);
      //strip.show();
      //voltage is too high
      if (PSV > (setvolt + 0.005)){pothigh = potnow;}
      //voltage is too low
      else if (PSV < (setvolt - 0.005)){potlow = potnow;}
      potnow = int((potlow + pothigh)/2);
      setpot(potnow);
      readPS();
      Serial.print("pothigh: ");
      Serial.println(pothigh);    
      Serial.print("potnow: ");
      Serial.print(potnow);
      Serial.print(", PS: ");
      Serial.println(PSV, 4);
      Serial.print("potlow: ");
      Serial.println(potlow);
      //digitalWrite (13, HIGH);
  }
}

void readPS(){
  Wire.beginTransmission(0x48);
  Wire.write(0b00000001);
  Wire.write(0b01010000);
  Wire.write(0b11100010);
  Wire.endTransmission();
  Wire.beginTransmission(0x48);
  Wire.write(0b00000000);
  Wire.endTransmission();
  delay(5);
  Wire.requestFrom(0x48, 2);
  adc1 = (Wire.read()<<8|Wire.read());
  PSV = adc1 * 0.1875 / 1000 * 16.482;
}

void setpot(int x){
 SPI.beginTransaction(SPISettings(50000000, MSBFIRST, SPI_MODE1));
 //set the pot
 digitalWrite(CSnp, LOW);
 SPI.transfer16(0x400 | x);
 digitalWrite(CSnp, HIGH);
 SPI.endTransaction();
 delay(300);
}
  

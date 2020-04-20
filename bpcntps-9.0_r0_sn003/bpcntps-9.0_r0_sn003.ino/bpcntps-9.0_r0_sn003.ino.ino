
#include <SPI.h>
#include <Wire.h>
#include "Adafruit_MCP9808.h"
#include <Adafruit_DotStar.h>

Adafruit_MCP9808 tempsensor = Adafruit_MCP9808();

#define fanpin 2
#define dsnumpixels 1
#define dsdatapin  7 //7 for box
#define dsclockpin 5 //5 for box
#define psonoffpin 11
#define CStarj A2
#define resetpin A4
#define holdpin A5
#define intpulsospin A3
#define CSpotpin 10
#define testpin 7
#define coeftempin A0
#define ledpin 13
#define PSFC 16.341

Adafruit_DotStar led(dsnumpixels, dsdatapin, dsclockpin, DOTSTAR_BRG);

uint32_t coloroff = led.Color(0, 0, 0);
uint32_t colorgreen = led.Color(0, 0, 255);
uint32_t colororange = led.Color(255, 122, 0);
uint32_t colormagenta = led.Color(255, 0, 255);
uint32_t colorcyan = led.Color(0, 255, 255);
uint32_t colorred = led.Color(0, 255, 0);
uint32_t colorblue = led.Color(255, 0, 0);

unsigned int chb[] = {1, 0, 0, 0, 0, 0, 0, 0};

int16_t adc0;
int16_t adc1;
int16_t adc2;
int16_t adc3;

int integral = 300;
//int regtime = 233;
int resettime = 70;

unsigned long previousMillis = 0;

//pot value in counts from 0 to 1023
int potlow;
int pothigh;
int potnow = 1;

float setvolt = 57.39;
float PSV;

float temp = 27;

//darkcurrents
unsigned int dcvch[] = {5000, 3000, 7000, 5000, 7000, 5000, 5000, 5000};
unsigned int dcvchmax[] = {6553, 65535, 65535, 65535, 65535, 65535, 65535, 65535};
unsigned int dcvchmin[] = {0, 0, 0, 0, 0, 0, 0, 0};

void setup() {

  //fan a 50Hz frequency 50% duty cycle

   MCLK->APBBMASK.reg |= MCLK_APBAMASK_TC1; //Activate Timer TC1
  // Set up the generic clock (GCLK7) to clock timer TC1
  GCLK->GENCTRL[7].reg = GCLK_GENCTRL_DIV(3) |       // Divide the 48MHz clock source by divisor 1: 48MHz/3 = 16MHz
                         GCLK_GENCTRL_IDC |          // Set the duty cycle to 50/50 HIGH/LOW
                         GCLK_GENCTRL_GENEN |        // Enable GCLK7
                         GCLK_GENCTRL_SRC_DFLL;      // Select 48MHz DFLL clock source
                         //GCLK_GENCTRL_SRC_DPLL1;     // Select 100MHz DPLL clock source
                         //GCLK_GENCTRL_SRC_DPLL0;     // Select 120MHz DPLL clock source
  while (GCLK->SYNCBUSY.bit.GENCTRL7);               // Wait for synchronization 

  GCLK->PCHCTRL[9].reg = GCLK_PCHCTRL_CHEN |        // Enable the TC1 peripheral channel
                         GCLK_PCHCTRL_GEN_GCLK7;    // Connect generic clock 7 to TC1

  // Enable the peripheral multiplexer on pin D2
  PORT->Group[g_APinDescription[2].ulPort].PINCFG[g_APinDescription[2].ulPin].bit.PMUXEN = 1;
 
  // Set the D2 (PORT_PA07) peripheral multiplexer to peripheral (Odd port number) O(4): TC1
  PORT->Group[g_APinDescription[2].ulPort].PMUX[g_APinDescription[2].ulPin >> 1].reg |= PORT_PMUX_PMUXO(4);
 
  TC1->COUNT16.CTRLA.reg = TC_CTRLA_PRESCALER_DIV16 | // Set prescaler to 16, 16MHz/16 = 1MHz
                           TC_CTRLA_PRESCSYNC_PRESC | // Set the reset/reload to trigger on prescaler clock
                           TC_CTRLA_MODE_COUNT16;     // Set the counter to 16-bit mode

  TC1->COUNT16.WAVE.reg = TC_WAVE_WAVEGEN_MPWM;       // Set-up TC1 timer for Match PWM mode (MPWM)
  
  TC1->COUNT16.CC[0].reg = 19999;                    // Use CC0 register as TOP value, set for 50Hz PWM
  while (TC1->COUNT16.SYNCBUSY.bit.CC0);             // Wait for synchronization

  TC1->COUNT16.CC[1].reg = 14999;                     // Set the duty cycle to 50% (CC1 half of CC0)
  while (TC1->COUNT16.SYNCBUSY.bit.CC1);             // Wait for synchronization

  TC1->COUNT16.CTRLA.bit.ENABLE = 1;                 // Enable timer TC1
  while (TC1->COUNT16.SYNCBUSY.bit.ENABLE);          // Wait for synchronization
  //pinMode (fanpin, OUTPUT);
  //analogWrite(fanpin, 255);

  //coeficiente de temp
  pinMode(coeftempin, OUTPUT);

  Serial.begin (115200);
  Wire.begin();
  SPI.begin();

  //DotStar
  led.begin();
  led.setBrightness(80);
  led.show(); //put Dot Star off

  //Connect the Power Supply
  //HIGH is connected
  pinMode (psonoffpin, OUTPUT);
  digitalWrite (psonoffpin, LOW);
  delay(2000);
  digitalWrite (psonoffpin, HIGH);

  //CStarjeta
  pinMode (CStarj, OUTPUT);
  digitalWrite (CStarj, HIGH);

  //RESET
  pinMode (resetpin, OUTPUT);
  digitalWrite (resetpin, HIGH);

  //HOLD
  pinMode (holdpin, OUTPUT);
  digitalWrite (holdpin, LOW);

  //Integradorpulsos
  pinMode (intpulsospin, OUTPUT);
  //HIGH for integrator
  //LOW for pulses
  digitalWrite (intpulsospin, HIGH);

  //newPOT
  pinMode(CSpotpin, OUTPUT);
  digitalWrite(CSpotpin, HIGH);

  //test pin
  //pinMode (testpin, OUTPUT);
  //digitalWrite (testpin, LOW);

  //dogwatcher
  pinMode(ledpin, OUTPUT);

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
  digitalWrite(CSpotpin, LOW);
  SPI.transfer16(0x1c02);
  digitalWrite(CSpotpin, HIGH);

  
  //Set range of all channels to +-2.5 * Vref
  SPI.beginTransaction(SPISettings(17000000, MSBFIRST, SPI_MODE1));
  //ch0
  digitalWrite(CStarj, LOW);
  SPI.transfer(0x05 << 1 | 1);
  SPI.transfer16(0x0000);
  digitalWrite(CStarj, HIGH);
  //ch1
  digitalWrite(CStarj, LOW);
  SPI.transfer(0x06 << 1 | 1);
  SPI.transfer16(0x0000);
  digitalWrite(CStarj, HIGH);
  //ch2
  digitalWrite(CStarj, LOW);
  SPI.transfer(0x07 << 1 | 1);
  SPI.transfer16(0x0000);
  digitalWrite(CStarj, HIGH);
  //ch3
  digitalWrite(CStarj, LOW);
  SPI.transfer(0x08 << 1 | 1);
  SPI.transfer16(0x0000);
  digitalWrite(CStarj, HIGH);
  //ch4
  digitalWrite(CStarj, LOW);
  SPI.transfer(0x09 << 1 | 1);
  SPI.transfer16(0x0000);
  digitalWrite(CStarj, HIGH);
  //ch5
  digitalWrite(CStarj, LOW);
  SPI.transfer(0x0A << 1 | 1);
  SPI.transfer16(0x0000);
  digitalWrite(CStarj, HIGH);
  //ch6
  digitalWrite(CStarj, LOW);
  SPI.transfer(0x0B << 1 | 1);
  SPI.transfer16(0x0000);
  digitalWrite(CStarj, HIGH);
  //ch7
  digitalWrite(CStarj, LOW);
  SPI.transfer(0x0C << 1 | 1);
  SPI.transfer16(0x0000);
  digitalWrite(CStarj, HIGH);

  SPI.endTransaction();
  

  regulatePS(); //at the begining regulate PS
  //sdc(); //at the begining subtract dark current
  //setpot(1023);
}

void loop() {

  //Serial.println("hola");  

  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= integral) {

    //digitalWrite(testpin, HIGH);
    //dogwatcher
    digitalWrite(ledpin, HIGH);
    led.setPixelColor(0, colorblue); //Dot star blue blinking 
    led.show();                       //indicates integrating

    ReadChannelsOnce();

    //digitalWrite (testpin, HIGH);

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
    adc0 = (Wire.read() << 8 | Wire.read());

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
    adc1 = (Wire.read() << 8 | Wire.read());

    Wire.beginTransmission(0x48);
    Wire.write(0b00000001);
    Wire.write(0b01100000);
    Wire.write(0b11100010);
    Wire.endTransmission();
    Wire.beginTransmission(0x48);
    Wire.write(0b00000000);
    Wire.endTransmission();
    delay(5);
    Wire.requestFrom(0x48, 2);
    adc2 = (Wire.read() << 8 | Wire.read());

    Wire.beginTransmission(0x48);
    Wire.write(0b00000001);
    Wire.write(0b01110100);
    Wire.write(0b11100010);
    Wire.endTransmission();
    Wire.beginTransmission(0x48);
    Wire.write(0b00000000);
    Wire.endTransmission();
    delay(5);
    Wire.requestFrom(0x48, 2);
    adc3 = (Wire.read() << 8 | Wire.read());

    temp = tempsensor.readTempC();

    Serial.print(currentMillis);
    Serial.print(",");
    Serial.print(temp, 4);
    Serial.print(",");
    Serial.print(chb[0]);
    Serial.print(",");
    Serial.print(chb[1]);
    Serial.print(",");
    Serial.print(chb[2]);
    Serial.print(",");
    Serial.print(chb[3]);
    Serial.print(",");
    Serial.print(chb[4]);
    Serial.print(",");
    Serial.print(chb[5]);
    Serial.print(",");
    Serial.print(chb[6]);
    Serial.print(",");
    Serial.print(chb[7]);
    Serial.print(",");
    //adc0 5V
    //para probar en Arduino
    //Serial.print(adc0 * 0.1875 / 1000, 4);
    Serial.print(adc0);
    Serial.print(",");
    //adc1 PS
    //to test with Arduino
    //Serial.print(adc1 * 0.1875 / 1000 * PSFC, 4);
    Serial.print(adc1); //never use this option 1 file per box
    Serial.print(",");
    //adc2 -12V
    //para probar en Arduino
    //Serial.print(adc2 * 0.1875 / 1000 * -2.6470, 4);
    Serial.print(adc2);
    Serial.print(",");
    //adc3 ref 1.25V
    //para probar en Arduion
    //Serial.println(adc3 * 0.0625 / 1000, 4);
    Serial.println(adc3);

    //digitalWrite(testpin, LOW);
    //dogwatcher
    digitalWrite(ledpin, LOW);
    led.setPixelColor(0, coloroff);
    led.show();
  }

  if (Serial.available() > 0) {
    char inChar = (char)Serial.read();
    
    if (inChar == 'r'){
      String PSs = Serial.readStringUntil(',');
      char comma = Serial.read(); //discard comma at the end
      Serial.println(PSs.toFloat(), 2);
      setvolt = PSs.toFloat();
      regulatePS();
    }
    
    if (inChar == 's'){
     sdc();
    }
    
    if (inChar == 'c'){
      String intts = Serial.readStringUntil(',');
      char pulsint = (char)Serial.read();
      //Serial.println(intts.toInt());
      //Serial.println(pulsint);
      integral = intts.toInt();
      
      if (pulsint == 'I') {
        //HIGH for integrator
        digitalWrite (intpulsospin, HIGH);
      }
      
      if (pulsint == 'P'){
        //LOW for pulses
        digitalWrite (intpulsospin, LOW);
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


void ReadChannels() {

  SPI.beginTransaction(SPISettings(17000000, MSBFIRST, SPI_MODE1));
  //initiate ch0 manual transfer
  //and read previous set ch7
  digitalWrite(CStarj, LOW);
  SPI.transfer16(0xC000);
  chb[7] = SPI.transfer16(0x0000);
  digitalWrite(CStarj, HIGH);
  //initiate ch1 manual transfer
  //and read previous set ch0
  digitalWrite (CStarj, LOW);
  SPI.transfer16 (0xC400);
  chb[0] = SPI.transfer16 (0x0000);
  digitalWrite (CStarj, HIGH);
  //initiate ch2 manual transfer
  //and read previous set ch1
  digitalWrite (CStarj, LOW);
  SPI.transfer16 (0xC800);
  chb[1] = SPI.transfer16 (0x0000);
  digitalWrite (CStarj, HIGH);
  //initiate ch3 manual transfer
  //and read previous set ch2
  digitalWrite (CStarj, LOW);
  SPI.transfer16 (0xCC00);
  chb[2] = SPI.transfer16 (0x0000);
  digitalWrite (CStarj, HIGH);
  //initiate ch4 manual transfer
  //and read previous set ch3
  digitalWrite (CStarj, LOW);
  SPI.transfer16 (0xD000);
  chb[3] = SPI.transfer16 (0x0000);
  digitalWrite (CStarj, HIGH);
  //initiate ch5 manual transfer
  //and read previous set ch4
  digitalWrite (CStarj, LOW);
  SPI.transfer16 (0xD400);
  chb[4] = SPI.transfer16 (0x0000);
  digitalWrite (CStarj, HIGH);
  //initiate ch6 manual transfer
  //and read previous set ch5
  digitalWrite (CStarj, LOW);
  SPI.transfer16 (0xD800);
  chb[5] = SPI.transfer16 (0x0000);
  digitalWrite (CStarj, HIGH);
  //initiate ch7 manual transfer
  //and read previous set ch6
  digitalWrite (CStarj, LOW);
  SPI.transfer16 (0xDC00);
  chb[6] = SPI.transfer16 (0x0000);
  digitalWrite (CStarj, HIGH);

  SPI.endTransaction();

  //ch0v = -(chb[0] * 20.48/65535) + 10.24;
  //ch1v = -(chb[1] * 20.48/65535) + 10.24;
  //ch2v = -(chb[2] * 20.48/65535) + 10.24;
  //ch3v = -(chb[3] * 20.48/65535) + 10.24;
  //ch4v = -(chb[4] * 20.48/65535) + 10.24;
  //ch5v = -(chb[5] * 20.48/65535) + 10.24;
  //ch6v = -(chb[6] * 20.48/65535) + 10.24;
  //ch7v = -(chb[7] * 20.48/65535) + 10.24;
}

void ReadChannelsOnce() {
  //digitalWrite(testpin, HIGH);
  //hold starts
  digitalWrite(holdpin, HIGH);
  ReadChannels();
  //Hold ends
  digitalWrite (holdpin, LOW);
  //digitalWrite (testpin, LOW);
  //reset the integration and a new integration process starts
  digitalWrite (resetpin, LOW);
  delayMicroseconds (resettime);
  digitalWrite (resetpin, HIGH);
  previousMillis = millis();
  //digitalWrite (testpin, HIGH);
}

void setvoltdc(int ch, unsigned int dcvch){
  Wire.beginTransmission(0xf);
  Wire.write(ch);
  Wire.write(dcvch >> 8);
  Wire.write(dcvch & 0xFF);
  Wire.endTransmission();
}

void regulatePS(){
  //measure PS once
  potlow = 0;
  pothigh = 1023;
  potnow = 512;
  setpot(potnow);
  readPS();


  while (PSV > (setvolt + 0.008) or PSV < (setvolt - 0.008)){
    led.setPixelColor(0, colorred); //Dot star orange blinking 
    led.show();                        //indicates regulating PS
    //voltage is too high
    if (PSV > (setvolt + 0.008)){
      pothigh = potnow;
    }
    //voltage is too low
    else if (PSV < (setvolt - 0.008)){
      potlow = potnow;
    }
    potnow = int((potlow + pothigh) / 2);
    setpot(potnow);
    readPS();
    led.setPixelColor(0, coloroff);
    led.show();
    Serial.print("setvolt: ");
    Serial.println(setvolt, 2);
    Serial.print("pothigh: ");
    Serial.println(pothigh);
    Serial.print("potnow: ");
    Serial.print(potnow);
    Serial.print(", PS: ");
    Serial.println(PSV, 4);
    Serial.print("potlow: ");
    Serial.println(potlow);
    //digitalWrite (ledpin, HIGH);

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
  adc1 = (Wire.read() << 8 | Wire.read());
  PSV = adc1 * 0.1875 / 1000 * PSFC;
}

void setpot(int x) {
  SPI.beginTransaction(SPISettings(50000000, MSBFIRST, SPI_MODE1));
  //set the pot
  digitalWrite(CSpotpin, LOW);
  SPI.transfer16(0x400 | x);
  digitalWrite(CSpotpin, HIGH);
  SPI.endTransaction();
  delay(300);
}

//function to substract dark current
void sdc(){
 unsigned int dcvch[] = {32767, 32767, 32767, 32767, 32767, 32767, 32767, 32767};
 unsigned int dcvchmax[] = {65535, 65535, 65535, 65535, 65535, 65535, 65535, 65535};
 unsigned int dcvchmin[] = {0, 0, 0, 0, 0, 0, 0, 0};
 for (int i = 0; i < 8; i++){
  dcvch[i] = (dcvchmin[i] + dcvchmax[i])/2;
  setvoltdc(i+16, dcvch[i]);
  while (millis() - previousMillis < integral){ 
  }
  ReadChannelsOnce();
  Serial.print(i);
  Serial.print(",dcvchmin,");
  Serial.print(dcvchmin[i]);
  Serial.print(",dcvch,");
  Serial.print(dcvch[i]);
  Serial.print(",dcvchmax,");
  Serial.print(dcvchmax[i]);
  Serial.print(",chb,");
  Serial.println(chb[i]);
  while (millis() - previousMillis < integral){ 
  }
  ReadChannelsOnce();
  
  while (chb[i] < 32742 or chb[i] > 32792){
   led.setPixelColor(0, colormagenta);//Dot star magenta blinking indicates
   led.show();//                        substractin dark current
   if (chb[i] < 32742){ //32717
    dcvchmin[i] = dcvch[i];
   }
   if (chb[i] > 32792){ //32817
    dcvchmax[i] = dcvch[i];
   }
   dcvch[i] = int((dcvchmin[i] + dcvchmax[i])/2);
   setvoltdc(i+16, dcvch[i]);
   while (millis() - previousMillis < integral){ 
   }
   ReadChannelsOnce();
   led.setPixelColor(0, coloroff);
   led.show();
   Serial.print(i);
   Serial.print(",dcvchmin,");
   Serial.print(dcvchmin[i]);
   Serial.print(",dcvch,");
   Serial.print(dcvch[i]);
   Serial.print(",dcvchmax,");
   Serial.print(dcvchmax[i]);
   Serial.print(",chb,");
   Serial.println(chb[i]);
   while (millis() - previousMillis < integral){ 
   }
   ReadChannelsOnce(); 
  }
 }
}



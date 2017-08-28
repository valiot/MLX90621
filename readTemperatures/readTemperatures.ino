/*
* A class for interfacing the Melexis 90620 Sensor from a Teensy 3.1
* Uses the 2c_t3 library for communication with the sensor
* 2013 by Felix Bonowski
* Based on a forum post by maxbot: http://forum.arduino.cc/index.php/topic,126244.msg949212.html#msg949212
* This code is in the public domain.
*
* Connection Instructions:
* Connect the Anode of a Silicon Diode to 3V Pin of Teensy. The Diode will drop ~0.7V, so the Cathode will be at ~2.7V. These 2.7V will be the supply voltage "VDD" for the sensor.
* Plug in the USB and measure the supply voltage with a multimeter! - it should be somewhere between 2.5V and 2.75V, else it will fry your precious sensor...
* ...disconnect USB again...
* Connect Teensy Pin 18 to 2.7V with a 4.7kOhm Resistor (Pullup)
* Connect Teensy Pin 19 to 2.7V with a 4.7kOhm Resistor (Pullup)
* Connect Teensy Pin 18 to I2C Data (SDA) Pin of Sensor
* Connect Teensy Pin 19 to I2C clock (SCL) Pin of Sensor
* Connect GND and 2.7V with a 100nF ceramic Capacitor.
* Connect the VSS Pin of the Sensor to GND.
* Connect the VDD Pin of the Sensor to 2.7V

 *  Created on: 9.7.2015
 *      Author: Robin van Emden
 */

#include <Arduino.h>
#include "MLX90621.h"

MLX90621 sensor; // create an instance of the Sensor class

void sendTemperatures(){
  for(int y=0;y<4;y++){ //go through all the rows
    Serial.print("[");
    
    for(int x=0;x<16;x++){ //go through all the columns
      double tempAtXY= sensor.getTemperature(y+x*4); // extract the temperature at position x/y
      Serial.print(tempAtXY);
         
      if (x<15) Serial.print(",");
    }
    Serial.print("]");
    if (y<3)Serial.print("~"); 
  }
  Serial.print("\n");
}

void setup(){ 
  Serial.begin(115200); //170ms a 19k2, 28ms a 115k2
  //Parpadea LED al reiniciarse el arduino
  pinMode(13, OUTPUT);
  for (int i = 0; i < 10; i++) 
    digitalWrite(13, !digitalRead(13));
  digitalWrite(13, LOW);
  //Serial.println(F("trying to initialize sensor..."));
  sensor.setRefreshRate(RATE_4HZ);
  sensor.setResolution(RES_18bit);
  sensor.setEmissivity(1.0);
  sensor.initialize (); // start the thermo cam
  //Serial.println(F("sensor initialized!"));
}
void loop(){
  sensor.measure(true); //get new readings from the sensor
  sendTemperatures();
  delay(32);
};

/*
long startTime = micros();
//Measured stuff
long elapsed = micros() - startTime;
Serial.print("measure time = ");
Serial.print((float)elapsed/1000.0);
Serial.println("ms");
*/




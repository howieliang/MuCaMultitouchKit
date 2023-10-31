//*********************************************
// Example Code for Designing UI for E-Tech (DUIET)
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

#include "Muca.h"
#define MICRO_S 100000

long timer = micros();

Muca muca;

int ledOn = 0; //to control the LED.

void setup() {
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);
  muca.skipLine(TX, (const short[]) {
    1, 2, 3, 4, 5, 6
  }, 6);
  muca.skipLine(RX, (const short[]) {
    9, 10, 11, 12
  }, 4);
  muca.init();
  muca.useRawData(true); // If you use the raw data, the interrupt is not working
}

void loop() {
  if (micros() - timer > MICRO_S) { //Timer: send sensor data in every 2ms
    timer = micros();
    getDataFromProcessing();
    Serial.flush(); //Flush the serial buffer
    GetRaw();
  }
}

void GetRaw() {
  if (muca.updated()) {
    for (int i = 0; i < NUM_ROWS * NUM_COLUMNS; i++) {
      if (muca.grid[i] > 0) Serial.print(muca.grid[i]);
      if (i != NUM_ROWS * NUM_COLUMNS - 1)
        Serial.print(",");
    }
    Serial.println();
  }
}

void getDataFromProcessing() {
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    if (inChar == 'a') { //when an 'a' charactor is received.
      ledOn = 1;
      digitalWrite(LED_BUILTIN, ledOn); //turn on the built in LED on Arduino Uno
    }
    if (inChar == 'b') { //when an 'b' charactor is received.
      ledOn = 0;
      digitalWrite(LED_BUILTIN, 0); //turn on the built in LED on Arduino Uno
    }
  }
}

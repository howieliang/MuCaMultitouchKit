//*********************************************
// Example Code for Designing UI for E-Tech (DUIET)
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

#include "Muca.h"
#define MICRO_S 100000
#define PWM_PIN 11

long timer = micros();

Muca muca;

int ledOn = 0; //to control the LED.

int lastLevel = 0;
int diff = 0;

void setup() {
  Serial.begin(115200);
  pinMode(LED_BUILTIN,OUTPUT);
  pinMode(PWM_PIN,OUTPUT);
  //  muca.skipLine(TX, (const short[]) {
  //    1,2,3,4,5,6,7,8,9,10
  //  }, 10);
  //  muca.skipLine(RX, (const short[]) {
  //    7,8,9,10,11,12
  //  }, 6);
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
  int v = map(max(min(lastLevel+diff,9),0), 0, 9, 0, 255);
  analogWrite(PWM_PIN, v); //turn on the built in LED on Arduino Uno
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
    if (inChar >= '0' && inChar <= '4') { //when an 'b' charactor is received.
      diff = inChar-'0'; //+0 ~ +4
    }
    if (inChar >= '5' && inChar <= '9') { //when an 'b' charactor is received.
      diff = inChar-'9'; //-0 ~ -4
    }
    if (inChar == 'c') { //when an 'b' charactor is received.
      lastLevel = max(min(lastLevel+diff,9),0);
      diff = 0;
    }
  }
}

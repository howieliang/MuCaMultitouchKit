//*********************************************
// Example Code for Designing UI for E-Tech (DUIET)
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

#include "Muca.h"
#define MICRO_S 100000

long timer = micros();

Muca muca;

void setup() {
  Serial.begin(115200);
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

#include <Servo.h>

Servo base;
Servo shoulder;
Servo elbow;

// State tracking to prevent "snapping"
bool active = false;

void setup() {
  Serial.begin(9600);
  // Motors are NOT attached yet. Arm is free to move.
}

void loop() {
  if (Serial.available() > 0) {
    char id = Serial.read(); // 'B', 'S', or 'E'
    int angle = Serial.parseInt();
    
    // Attach motors only on first valid command
    if (!active) {
      base.attach(9);
      shoulder.attach(10);
      elbow.attach(11);
      active = true;
    }
    
    if (id == 'B') base.write(angle);
    else if (id == 'S') shoulder.write(angle);
    else if (id == 'E') elbow.write(angle);
    
    // Clear buffer
    while(Serial.available() > 0) Serial.read();
  }
}
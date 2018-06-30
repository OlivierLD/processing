import processing.io.*;
VL53L0X vl53l0x;

// see setup.png in the sketch folder for wiring details

void setup() {
  size(720, 120);
  textSize(72);

  //printArray(I2C.list());
  vl53l0x = new VL53L0X(I2C.list()[0], VL53L0X.VL53L0X_I2CADDR);
}

int previousDist = -1;

void draw() {
  background(0);
  stroke(255);

  int mm = vl53l0x.range();
  if (previousDist != mm) {
    println(String.format("Range: %d mm", mm));
  }
  previousDist = mm;

  text(String.format("Range: %d mm", mm), 10, 75);
}

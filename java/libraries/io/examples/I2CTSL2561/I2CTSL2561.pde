import processing.io.*;

TSL2561 tsl2561;

void setup() {
  size(700, 120);
  textSize(72);
  tsl2561 = new TSL2561(I2C.list()[0], TSL2561.TSL2561_ADDRESS);
}

double lux = 0d;

void draw() {
  background(0);
  stroke(255);
  try {
    lux = tsl2561.readLux();
  } catch (ArithmeticException ae) {
    println("Not on a PI? No device?");
    lux = 0d;
  } catch (Exception ex) {
    ex.printStackTrace();
  }
  text(String.format("Light:  %.02f Lux", lux), 10, 75);
}

void dispose() {
  tsl2561.turnOff();
  println("Turning Off");
}

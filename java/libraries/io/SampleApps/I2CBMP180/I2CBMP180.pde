import processing.io.*;

BMP180 bmp180;

void setup() {
  size(720, 280);
  textSize(72);
  System.setProperty("bmp180.verbose", "false");
  bmp180 = new BMP180();
}

float temp = 0f, press = 0f;

void draw() {
  background(0);
  stroke(255);
  try {
    temp = bmp180.readTemperature();
    press = bmp180.readPressure();
  } catch (ArithmeticException ae) {
    println("Not on a PI? No device?");
  } catch (Exception ex) {
    ex.printStackTrace();
  }
  text(String.format("Temp:  %.02f\272C", temp), 10, 75);
  text(String.format("Press: %.02f hPa", press / 100f), 10, 145);
}

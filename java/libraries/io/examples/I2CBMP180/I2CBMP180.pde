import processing.io.*;

BMP180 bmp180;

void setup() {
  size(700, 240);
  textSize(72);
  bmp180 = new BMP180(I2C.list()[0], BMP180.BMP180_I2CADDRESS);
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
    temp = 20f;
    press = 101360f;
  } catch (Exception ex) {
    ex.printStackTrace();
  }
  text(String.format("Temp:  %.02f\272C", temp), 10, 75);
  text(String.format("Press: %.02f hPa", press / 100f), 10, 150);
	text(String.format("Alt: %.02f m", bmp180.altitude(press, temp)), 10, 225);
}

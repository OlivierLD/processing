import processing.io.*;

HMC5883L hmc5883l;

void setup() {
  size(880, 120);
  textSize(72);
  hmc5883l = new HMC5883L(I2C.list()[0], HMC5883L.HMC5883L_ADDRESS);
}

double heading = 0d;

void draw() {
  background(0);
  stroke(255);
  try {
    hmc5883l.read();
    heading = hmc5883l.getHeading();
  } catch (ArithmeticException ae) {
    println("Not on a PI? No device?");
    heading = 0d;
  } catch (Exception ex) {
    ex.printStackTrace();
  }
  text(String.format("Heading (mag):  %.02f\272", heading), 10, 75);
}

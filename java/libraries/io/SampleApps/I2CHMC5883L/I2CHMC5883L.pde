import processing.io.*;

HMC5883L hmc5883l;

int centerX = 200;
int centerY = 200;
int intRadius =  20;
int extRadius = 190;

void setup() {
  size(400, 400);
//stroke(255);
  noStroke();
  noFill();
  textSize(10);
  hmc5883l = new HMC5883L(I2C.list()[0], HMC5883L.HMC5883L_ADDRESS);
}

float heading = 0f;

void draw() {
  background(0);
  stroke(255);
  try {
    hmc5883l.read();
    heading = (float)hmc5883l.getHeading();
  } catch (ArithmeticException ae) {
    println("Not on a PI? No device?");
    heading = 0f;
  } catch (Exception ex) {
    ex.printStackTrace();
  }
  textSize(10);
  fill(255);
  text(String.format("%05.1f\272", heading), 5, 12);

  // Drawing the rose
  float _heading = (-heading) + 90;
  for (int q=0; q<4; q++) {
    fill(255); // White
    triangle(centerX,
             centerY,
             (float)(centerX + (extRadius * Math.cos(Math.toRadians(_heading)))),
             (float)(centerY + (extRadius * Math.sin(Math.toRadians(_heading)))),
             (float)(centerX + (intRadius * Math.cos(Math.toRadians(_heading + 45)))),
             (float)(centerY + (intRadius * Math.sin(Math.toRadians(_heading + 45)))));
    fill(128); // Gray
    triangle(centerX,
             centerY,
             (float)(centerX + (extRadius * Math.cos(Math.toRadians(_heading)))),
             (float)(centerY + (extRadius * Math.sin(Math.toRadians(_heading)))),
             (float)(centerX + (intRadius * Math.cos(Math.toRadians(_heading - 45)))),
             (float)(centerY + (intRadius * Math.sin(Math.toRadians(_heading - 45)))));
    _heading += 90;
  }
  // print the North
  textSize(32);
  fill(255, 204, 0); // Goldish
  pushMatrix();
  translate(centerX + (extRadius * (float)Math.cos(Math.toRadians((-heading) - 90))),
            centerY + (extRadius * (float)Math.sin(Math.toRadians((-heading) - 90))));
  rotate((float)Math.toRadians(-heading));
  String north = "N";
  float w = textWidth(north);
  text(north, -w / 2, 40);
  popMatrix();
}

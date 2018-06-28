import processing.io.*;

PCA9685 pca9685;

int SERVO_PORT = 15;

int freq = 60;
int servoMin = 122;
int servoMax = 615;

void setup() {
  pca9685 = new PCA9685(I2C.list()[0], PCA9685.PCA9685_ADDRESS);
  pca9685.setPWMFreq(freq); // Set frequency to 60 Hz

  noLoop();
}

void draw() {
  pca9685.setPWM(SERVO_PORT, 0, 0);   // Stop the servo

  for (int i = servoMin; i <= servoMax; i++) {
    println("Part 1 - i=" + i);
    pca9685.setPWM(SERVO_PORT, 0, i);
    delay(1);
  }
  for (int i = servoMax; i >= servoMin; i--) {
    println("Part 2 - i=" + i);
    pca9685.setPWM(SERVO_PORT, 0, i);
    delay(1);
  }

  pca9685.setPWM(SERVO_PORT, 0, 0);   // Stop the servo
  println("Done with the demo.");
}

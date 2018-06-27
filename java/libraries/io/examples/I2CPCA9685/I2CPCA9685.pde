import processing.io.*;

PCA9685 pca9685;

int CONTINUOUS_SERVO_CHANNEL = 14;
int STANDARD_SERVO_CHANNEL = 15;

int freq = 60;
int servoMin = 122; // 130;   // was 150. Min pulse length out of 4096
int servoMax = 615;   // was 600. Max pulse length out of 4096

void setup() {
  pca9685 = new PCA9685(I2C.list()[0], PCA9685.PCA9685_ADDRESS);
  pca9685.setPWMFreq(freq); // Set frequency to 60 Hz

  noLoop();
}

void draw() {
  pca9685.setPWM(CONTINUOUS_SERVO_CHANNEL, 0, 0); // Stop the continuous one
  pca9685.setPWM(STANDARD_SERVO_CHANNEL, 0, 0);   // Stop the standard one
  System.out.println("Done with the demo.");

  for (int i = servoMin; i <= servoMax; i++) {
    println("Part 1 - i=" + i);
    pca9685.setPWM(STANDARD_SERVO_CHANNEL, 0, i);
    delay(10);
  }
  for (int i = servoMax; i >= servoMin; i--) {
    println("Part 2 - i=" + i);
    pca9685.setPWM(STANDARD_SERVO_CHANNEL, 0, i);
    delay(10);
  }

  pca9685.setPWM(CONTINUOUS_SERVO_CHANNEL, 0, 0); // Stop the continuous one
  pca9685.setPWM(STANDARD_SERVO_CHANNEL, 0, 0);   // Stop the standard one

  for (int i = servoMin; i <= servoMax; i++) {
    println("Part 3 - i=" + i);
    pca9685.setPWM(CONTINUOUS_SERVO_CHANNEL, 0, i);
    delay(100);
  }
  for (int i = servoMax; i >= servoMin; i--) {
    println("Part 4 - i=" + i);
    pca9685.setPWM(CONTINUOUS_SERVO_CHANNEL, 0, i);
    delay(100);
  }

  pca9685.setPWM(CONTINUOUS_SERVO_CHANNEL, 0, 0); // Stop the continuous one
  pca9685.setPWM(STANDARD_SERVO_CHANNEL, 0, 0);   // Stop the standard one
  
  println("Done with the demo.");
}

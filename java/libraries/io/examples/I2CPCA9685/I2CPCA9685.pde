import processing.io.*;

PCA9685 pca9685;

int SERVO_1 = 15;
int SERVO_2 = 14;

int freq = 60;
int servoMin = 122;
int servoMax = 615;

void setup() {
	size(400, 300);

	pca9685 = new PCA9685(I2C.list()[0], PCA9685.PCA9685_ADDRESS);
  pca9685.setPWMFreq(freq); // Set frequency to 60 Hz
  // Reset servos
  pca9685.setPWM(SERVO_1, 0, 0);
  pca9685.setPWM(SERVO_2, 0, 0);
}

void draw() {
  background(0);
  stroke(255);
  strokeWeight(3);

  float angle1 = sin(frameCount / 100.0) * 85;
  float angle2 = cos(frameCount / 100.0) * 85;

  setAngle(SERVO_1, angle1);
  setAngle(SERVO_2, angle2);

  float y = map(angle1, -90, 90, 0, height);
  line(0, y, width/2, y);

  y = map(angle2, -90, 90, 0, height);
  line(width/2, y, width, y);
}

void dispose() {
  // Park the servos
  pca9685.setPWM(SERVO_1, 0, 0); 
  pca9685.setPWM(SERVO_2, 0, 0);
  println("Done with the demo.");
}

// Utility methods
private void setAngle(int servo, float f) {
  int pwm = degreeToPWM(servoMin, servoMax, f);
//String mess = String.format("Servo %d, angle %.02f\272, pwm: %d", servo, f, pwm);
//println(mess);
  try {
      pca9685.setPWM(servo, 0, pwm);
  } catch (IllegalArgumentException iae) {
    println(String.format("Cannot set servo %d to PWM %d", servo, pwm));
    iae.printStackTrace();
  }
}

/*
 * deg in [-90..90]
 */
int degreeToPWM(int min, int max, float deg) {
  int diff = max - min;
  float oneDeg = diff / 180f;
  return Math.round(min + ((deg + 90) * oneDeg));
}

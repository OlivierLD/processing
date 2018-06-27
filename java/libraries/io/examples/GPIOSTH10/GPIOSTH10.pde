import processing.io.*;

STH10 sth10;

int DATA = 18,
    CLOCK = 23;

void setup() {
  size(600, 200);
  noStroke();
  noFill();
  textSize(72);
	sth10 = new STH10(DATA, CLOCK);
}

double temp, hum;

void draw() {
  background(0);
  stroke(255);

  try {
    temp = sth10.readTemperature();
    hum = sth10.readHumidity();
  } catch (RuntimeException re) { // Bad wiring, or bad sensor...
    temp = 20d;
    hum = 50d;
  }
  text(String.format("Temp:  %.02f\272C", temp), 10, 75);
  text(String.format("Hum:   %.02f %%", hum), 10, 150);
}

void dispose() {
  if (!NativeInterface.isSimulated()) {
    GPIO.releasePin(DATA);
    GPIO.releasePin(CLOCK);
  }
  println("Bye!");
}

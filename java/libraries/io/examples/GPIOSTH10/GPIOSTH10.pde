import processing.io.*;

STH10 sth10;

int DATA = 18,
    CLOCK = 23;
    
void setup() {
  System.setProperty("sth10.verbose", "true");
	sth10 = new STH10(DATA, CLOCK);
}

void draw() {
 double temp = sth10.readTemperature();
 double hum = sth10.readHumidity();
 println(String.format("Temp %.02f\272C, Hum %02f%%", temp, hum));
}

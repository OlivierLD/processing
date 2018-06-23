import processing.io.*;

STH10 sth10;

void setup() {
	sth10 = new STH10(18, 23);
}

void draw() {
 double temp = sth10.readTemperature();
 double hum = sth10.readHumidity();
 println(String.format("Temp %.02f\272C, Hum %02f%%", temp, hum));
}

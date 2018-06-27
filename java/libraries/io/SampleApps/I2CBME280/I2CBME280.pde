import processing.io.*;

BME280 bme280;

void setup() {
	size(720, 280);
  textSize(72);
  System.setProperty("bme280.verbose", "false");
	bme280 = new BME280();
}

void draw() {
	background(0);
	stroke(255);
  try {
	  float temp = bme280.readTemperature();
	  float hum = bme280.readHumidity();
	  float press = bme280.readPressure();
    text(String.format("Temp:  %.02f\272C", temp), 10, 75);
    text(String.format("Hum:   %.02f %%", hum), 10, 150);
    text(String.format("Press: %.02f hPa", press / 100f), 10, 225);
    // At sea level
    BME280Data allData = bme280.getAllData(); // 101325F);
    if ("true".equals(System.getProperty("bme280.verbose", "false"))) {
      println(String.format("T: %.02f\272C\nH:  %.02f %%\nP:  %.02f hPa\nA:  %.02f m",
      allData.getTemp(),
      allData.getHum(),
      allData.getPress() / 100f,
      allData.getAlt()));
    }
  } catch (Exception ex) {
    ex.printStackTrace();
  }
}

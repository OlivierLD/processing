import processing.io.*;

STH10 sth10;

int DATA = 18,
    CLOCK = 23;

int centerX = 200;
int centerY = 200;
int tubeBottom = 380;
int intRadius =  20;
int extRadius = 180;


List<Float> humBuffer;
List<Float> tempBuffer;
int MAX_BUFFER_SIZE = 200;

void setup() {
	System.setProperty("sth10.verbose", "false");
	if ("true".equals(System.getProperty("sth10.verbose"))) {
		println("Setup");
	}
  size(520, 600);
  noStroke();
  noFill();
  textSize(10);
	sth10 = new STH10(DATA, CLOCK);
  humBuffer = new ArrayList<Float>(MAX_BUFFER_SIZE);
  tempBuffer = new ArrayList<Float>(MAX_BUFFER_SIZE);
  frameRate(1f); // once per second
	if ("true".equals(System.getProperty("sth10.verbose"))){
		println("Let's go");
	}
}

int humidityFrom = 0, humidityTo = 100;
int temperatureFrom = -20, temperatureTo = 50;

double temp, hum;

void draw() {
  if ("true".equals(System.getProperty("sth10.verbose"))) {
    println("Drawing");
  }
  background(0);
  try {
    try {
      temp = sth10.readTemperature();
      hum = sth10.readHumidity();
    } catch (RuntimeException re) { // Bad wiring, or bad sensor...
      temp = Simulators.TempSimulator.get();
      hum = Simulators.HumSimulator.get();
    }
    humBuffer.add(new Float(hum));
    tempBuffer.add(new Float(temp));
    while (humBuffer.size() > MAX_BUFFER_SIZE) {
      humBuffer.remove(0);
    }
    while (tempBuffer.size() > MAX_BUFFER_SIZE) {
      tempBuffer.remove(0);
    }
    if ("true".equals(System.getProperty("sth10.verbose"))) {
      println(String.format("Temp %.02f\272C, Hum %02f%%", temp, hum));
    }
    if (NativeInterface.isSimulated()) {
      hum = Math.min(hum, humidityTo);
      hum = Math.max(hum, humidityFrom);
      temp = Math.min(temp, temperatureTo);
      temp = Math.max(temp, temperatureFrom);
    }
    drawDisplay((float)hum,
                humidityFrom,
                humidityTo,
                10,
                1,
                0,
                0,
                color(0, 255, 255), // Cyan
                "%",
                "Humidity");

    drawTube((float)temp,
             temperatureFrom,
             temperatureTo,
             20,                 // tube width
             270,                // tube height
             (2 * centerX) + 40, // X Offset
             0,                  // Y Offset
             color(0, 255, 0),   // tick color, green.
             1,                  // minor
             5,                  // Major
             "\272C");           // Unit
    
    drawGraph();            
  } catch (Exception ex) {
    ex.printStackTrace();
  }
}

void dispose() {
  if (!NativeInterface.isSimulated()) {
		if ("true".equals(System.getProperty("sth10.verbose"))){
		  println("Returning the pins to the system");
		}
    GPIO.releasePin(DATA);
    GPIO.releasePin(CLOCK);
  }
  println("Bye!");
}

/**
 * Generic.
 * Provide: value, from, to, minor ticks, major ticks, xOffset, yOffset
 */
void drawDisplay(float value, int from, int to, int majorTicks, int minorTicks, int xOffset, int yOffset, color c, String unit, String label) {
  float sectorToCover = 260f; // On 260 degrees
  textSize(10);
  fill(255);
  text(String.format("%05.2f %s", value, unit), 5 + xOffset, 12);

  // The ticks
  stroke(c);
  for (int p=from; p<=to; p+=minorTicks) {
    strokeWeight((p % majorTicks == 0 ? 3 : 1));
    float _p = ((p - ((from + to) / 2)) * (sectorToCover / (to - from))) - 90f;
    line(centerX + xOffset + ((extRadius + 5) * (float)Math.cos(Math.toRadians(_p))),
         centerY + yOffset + ((extRadius + 5) * (float)Math.sin(Math.toRadians(_p))),
         centerX + xOffset + ((extRadius - (p % majorTicks == 0 ? 20 : 10)) * (float)Math.cos(Math.toRadians(_p))),
         centerY + yOffset + ((extRadius - (p % majorTicks == 0 ? 20 : 10)) * (float)Math.sin(Math.toRadians(_p))));
  }
  strokeWeight(1);
  stroke(255);

  // Label
  textSize(32);
  fill(c);
  float strW = textWidth(label);
  text(label, (centerX + xOffset) - (strW / 2), (centerY + yOffset) - (extRadius * .50) + 32);

  // Drawing the hand
  float _value = ((value - ((from + to) / 2)) * (sectorToCover / (to - from))) - 90f;
//println(String.format("Pressure: %.02f, Angle: %f", pressure, _pressure));
  fill(255); // White
  triangle(centerX + xOffset,
           centerY + yOffset,
           (float)(centerX + xOffset + (extRadius * Math.cos(Math.toRadians(_value)))),
           (float)(centerY + yOffset + (extRadius * Math.sin(Math.toRadians(_value)))),
           (float)(centerX + xOffset + (intRadius * Math.cos(Math.toRadians(_value + 45)))),
           (float)(centerY + yOffset + (intRadius * Math.sin(Math.toRadians(_value + 45)))));
  fill(128); // Gray
  triangle(centerX + xOffset,
           centerY + yOffset,
           (float)(centerX + xOffset + (extRadius * Math.cos(Math.toRadians(_value)))),
           (float)(centerY + yOffset + (extRadius * Math.sin(Math.toRadians(_value)))),
           (float)(centerX + xOffset + (intRadius * Math.cos(Math.toRadians(_value - 45)))),
           (float)(centerY + yOffset + (intRadius * Math.sin(Math.toRadians(_value - 45)))));

  // knob
  fill(180); // Grey'ish
  ellipse(centerX + xOffset, centerY + yOffset, intRadius * 2, intRadius * 2);

  // print the Value
  textSize(32);
  fill(c);
  String str = String.format("%05.2f %s", value, unit);
  strW = textWidth(str);
  text(str, (centerX + xOffset) - (strW / 2), (centerY + yOffset) + (extRadius * .50));
}

void drawTube(float value, int from, int to, int tubeWidth, int tubeHeight, int xOffset, int yOffset, color tickColor, int minor, int major, String unit) {
  // Ticks here
  fill(tickColor);
  strokeWeight(1);
  stroke(tickColor);
  for (int t=from; t<=to; t+=minor) {
    float y = tubeBottom + yOffset - (tubeWidth * 1.5) - ((t - from) * (float)tubeHeight / (float)(to - from));
    strokeWeight(t == 0 ? 3 : 1);
    line(xOffset - (t % major == 0 ? tubeWidth : (tubeWidth * 0.75)),
         y,
         xOffset + (t % major == 0 ? tubeWidth : (tubeWidth * 0.75)),
         y);
    if (t == 0) {
      textSize(12);
      text("0" + unit, xOffset + (tubeWidth * 1.5), y + 4);
    }
  }

  fill(180);
  noStroke();
  ellipse(xOffset, tubeBottom + yOffset - (tubeWidth * 1.5), tubeWidth * 1.5, tubeWidth * 1.5); // Bottom
  ellipse(xOffset, tubeBottom + yOffset - (tubeWidth * 1.5) - tubeHeight, tubeWidth, tubeWidth); // Top
  rect(xOffset - (tubeWidth / 2), tubeBottom + yOffset - (tubeWidth * 1.5) - tubeHeight, tubeWidth, tubeHeight); // body
  fill(255, 0, 0);
  ellipse(xOffset, tubeBottom + yOffset - (tubeWidth * 1.5), tubeWidth * 1.1, tubeWidth * 1.1); // Bottom, red.
  // Value
  float _value = (value - from) * (float)tubeHeight / (float)(to - from);
  rect(xOffset - ((tubeWidth * 0.6) / 2), tubeBottom + yOffset - (tubeWidth * 1.5), (tubeWidth * 0.6), - _value); // body, red

  textSize(32);
  fill(tickColor);
  String label = String.format("%.01f %s", value, unit);
  float strW = textWidth(label);
  text(label, xOffset - (strW / 2), 40 + yOffset);
}

int graphHeight = 190;
void drawGraph() {
//println(String.format("Hum: %d, Temp: %d", humBuffer.size(), tempBuffer.size()));
  if (humBuffer.size() > 0 && tempBuffer.size() > 0) {
    fill(255); // white
    rect(10, 400, width - 20, graphHeight);
    stroke(0, 0, 255); // blue
    Iterator<Float> humIter = humBuffer.iterator();
    int idx = 0;
    float prevX = -1, prevY = -1;
    while (humIter.hasNext()) {
      float f = humIter.next().floatValue();
      float x = ((float)idx / (float)(humBuffer.size() - 1)) * (float)(width - 20);
      float y = ((f - humidityFrom) / (humidityTo - humidityFrom)) * graphHeight;
//    println(String.format("Idx %d, x:%f, y:%f", idx, x, y));
      if (prevX != -1 && prevY != -1) { // Draw line
        line(prevX + 10, 400 + (graphHeight - prevY), x + 10, 400 + (graphHeight - y));
      }
      prevX = x;
      prevY = y;
      idx++;
    }
    stroke(255, 0, 0); // red
    Iterator<Float> tempIter = tempBuffer.iterator();
    idx = 0;
    prevX = -1; 
    prevY = -1;
    while (tempIter.hasNext()) {
      float f = tempIter.next().floatValue();
      float x = ((float)idx / (float)(tempBuffer.size() - 1)) * (float)(width - 20);
      float y = ((f - temperatureFrom) / (temperatureTo - temperatureFrom)) * graphHeight;
//    println(String.format("Idx %d, x:%f, y:%f", idx, x, y));
      if (prevX != -1 && prevY != -1) { // Draw line
        line(prevX + 10, 400 + (graphHeight - prevY), x + 10, 400 + (graphHeight - y));
      }
      prevX = x;
      prevY = y;
      idx++;
    }
  }
}

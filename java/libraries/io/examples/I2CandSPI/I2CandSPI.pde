import processing.io.*;

/**
 * MCP3008, channel 0 on a potentiometer
 * ADC value will be displayed on the OLED (SSD1306)
 */

MCP3008 adc;

SSD1306 oled;
ScreenBuffer sb;

Mode SCREEN_FLAVOR = Mode.WHITE_ON_BLACK;

final int ADC_CHANNEL = 0;
final int NB_LINES = 32;
final int NB_COLS = 128;

final int BLACK = 0;
final int WHITE = 255;
final int GRAY = 100;
final color RED = color(255, 0, 0);

final int WIDTH = 768;
final int HEIGHT = 192;

final int CELL_SIZE = 6;

void setup() {
  adc = new MCP3008(SPI.list()[0]);
  
  frameRate(4); // fps. Default is 60. Slow down to 4, to be able to read.
  initLeds();
  size(768, 192); // (WIDTH, HEIGHT);
  stroke(BLACK);
  noFill();
  textSize(72); // if text() is used.

  try {
    println(String.format("SSD1306 address: 0x%02X", SSD1306.SSD1306_I2C_ADDRESS));
    oled = new SSD1306(SSD1306.SSD1306_I2C_ADDRESS);
    oled.clear();
  } catch (Exception ex) {
    oled = null;
    println("Cannot find the device, moving on without it.");
  }

}

void draw() {
  float value = adc.getAnalog(ADC_CHANNEL) * 1023f;

  background(BLACK);
  fill(WHITE);
  
  drawOLED(value);
}

void drawOLED(float value) {
  stroke(GRAY); // For the grid
  // Vertical grid
  for (int i=1; i<NB_COLS; i++) {
    int abs = i * (int)(WIDTH / NB_COLS);
    line(abs, 0, abs, HEIGHT);
  }
  // Horizontal grid
  for (int i=0; i<NB_LINES; i++) {
    int ord = i * (int)(HEIGHT / NB_LINES);
    line(0, ord, WIDTH, ord);
  }

  // Character display
  if (sb == null) {
    sb = new ScreenBuffer(NB_COLS, NB_LINES);
  }
  sb.clear(SCREEN_FLAVOR);

  println(String.format("- %4.1f -", value));
  String text = String.format("- %4.1f -", value);
  int fontFactor = 3;
  int len = sb.strlen(text) * fontFactor;
  sb.text(text, 62 - (len / 2), 11, fontFactor, SCREEN_FLAVOR);
  if (oled != null) {
    oled.setBuffer(sb.getScreenBuffer());
    oled.display();
  } else {
    println("No device");
  }
  this.setBuffer(sb.getScreenBuffer());
  this.display();
}

void dispose() {
  if (oled != null) {
    sb.clear();
    oled.clear(); // Blank screen
    oled.setBuffer(sb.getScreenBuffer());
    oled.display();
  }
  println("Bye!");
}

void display() {
  fill(RED);
  boolean[][] leds = getLedOnOff();
  for (int col=0; col<leds.length; col++) {
    for (int line=0; line<leds[col].length; line++) {
      if (leds[col][line]) {
        int x = (CELL_SIZE * col) + (CELL_SIZE / 2);
        int y = (CELL_SIZE * line) + (CELL_SIZE / 2);
        ellipse(x, y, 8, 8);
      }
    }
  }
}

boolean[][] ledOnOff;

void setLedOnOff(boolean[][] ledOnOff) {
  this.ledOnOff = ledOnOff;
}

boolean[][] getLedOnOff() {
  return ledOnOff;
}

void initLeds() {
  ledOnOff = new boolean[NB_COLS][NB_LINES];
  for (int r = 0; r < NB_LINES; r++) {
    for (int c = 0; c < NB_COLS; c++)
      ledOnOff[c][r] = false;
  }
}

void setBuffer(byte[] screenbuffer) {
  // This displays the buffer top to bottom, instead of left to right
  char[][] screenMatrix = new char[NB_LINES][NB_COLS];
  for (int i = 0; i < NB_COLS; i++) {
    // Line is a vertical line, made of (NB_LINES / 8) chunks.
    String line = "";
    for (int l = (NB_LINES / 8) - 1; l >= 0; l--) {
      int v = screenbuffer[i + (l * NB_COLS)] & 0xFF;
      String chunk = lpad(Integer.toBinaryString(v), 8, "0").replace('0', ' ').replace('1', 'X');
      line += chunk;
    }
//  println("line: [" + line + "], length:" + line.length());
    for (int c = 0; c < line.length(); c++) {
      try {
        char mc = line.charAt(c);
        screenMatrix[c][i] = mc;
      } catch (Exception ex) {
        println("Line:" + line + " (" + line.length() + " character(s))");
        ex.printStackTrace();
      }
    }
  }
  // Display the screen matrix, as it should be seen
  boolean[][] matrix = this.getLedOnOff();
  for (int i = 0; i < NB_LINES; i++) {
    for (int j = 0; j < NB_COLS; j++) {
      matrix[j][NB_LINES - 1 - i] = (screenMatrix[i][j] == 'X' ? true : false);
    }
  }
  this.setLedOnOff(matrix);
}

String lpad(String s, int len) {
  return lpad(s, len, " ");
}

String lpad(String s, int len, String pad) {
  String str = s;
  while (str.length() < len) {
    str = pad + str;
  }
  return str;
}

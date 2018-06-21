/*
 * Sends data to the SSD1306, and emulates it.
 * Both displays (oled and Processing Frame) should look the same.
 *
 * Print on the screen, AND on the emulator
 * If option == RANDOM, print random numbers [0..1023]
 * If option == STATIC_TEXT, print a static text
 * If option == IMAGE, print an image
 * If option == GRAPHIC will randomly display geometric shaped
 */

int RANDOM = 0;
int STATIC_TEXT = 1;
int IMAGE = 2;
int GRAPHIC = 3;

int option = RANDOM;
int value;

final int NB_LINES = 32;
final int NB_COLS = 128;

final int BLACK = 0;
final int WHITE = 255;
final int GRAY = 100;
final color RED = color(255, 0, 0);

final int WIDTH = 768;
final int HEIGHT = 192;

final int CELL_SIZE = 6;

Mode SCREEN_FLAVOR = Mode.WHITE_ON_BLACK;

SSD1306 oled;
ScreenBuffer sb;
ImgInterface img;

void setup() {
  frameRate(4); // fps. Default is 60. Slow down to 4, to be able to read.
  initLeds();
  size(768, 192); // (WIDTH, HEIGHT);
  stroke(BLACK);
  noFill();
  textSize(72); // if text() is used.

	if (option == IMAGE) {
		img = new Java32x32();
    SCREEN_FLAVOR = Mode.BLACK_ON_WHITE;
	}

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
  background(BLACK);
  fill(WHITE);
  value = (int)Math.floor(1023 * Math.random());  // Simulation
//text(String.format("%04d", value), 10, 100);

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

  if (option == STATIC_TEXT) {
    sb.text("ScreenBuffer", 2, 9, SCREEN_FLAVOR);
    sb.text(NB_COLS + " x " + NB_LINES + " for LCD", 2, 19, SCREEN_FLAVOR);
    sb.text("I speak Processing!", 2, 29, SCREEN_FLAVOR);
  } else if (option == RANDOM) {
    String text = String.format("- %04d -", value);
    int fontFactor = 3;
    int len = sb.strlen(text) * fontFactor;
    sb.text(text, 62 - (len / 2), 11, fontFactor, SCREEN_FLAVOR);
  } else if (option == IMAGE) {
		sb.image(img, 0, 0, Mode.BLACK_ON_WHITE);
		sb.text("I speak Java!", 36, 20, Mode.BLACK_ON_WHITE);
	} else if (option == GRAPHIC) {
    int gOption = (int)Math.round(Math.random() * 3); // Random option
//  println(String.format("G Option: %d", gOption));
    switch (gOption) {
      case 0:
        sb.line(1, 1, 126, 30);
        sb.line(126, 1, 1, 30);
        sb.line(1, 25, 120, 10);
        sb.line(10, 5, 10, 30);
        sb.line(1, 5, 120, 5);
        break;
      case 1:
//      sb.rectangle(5, 10, 100, 25);
//      sb.rectangle(15, 3, 50, 30);
        for (int i = 0; i < 8; i++) {
          sb.rectangle(1 + (i * 2), 1 + (i * 2), 127 - (i * 2), 31 - (i * 2));
        }
        break;
      case 2:
        sb.plot(64, 16);
        int[] x = new int[]{64, 73, 50, 78, 55};
        int[] y = new int[]{1, 30, 12, 12, 30};
        Polygon p = new Polygon(x, y, 5);
        sb.shape(p, true);
        break;
      case 3:
        sb.circle(64, 16, 15);
        sb.circle(74, 16, 10);
        sb.circle(80, 16, 5);
        sb.arc(100, 16, 10, 20, 90);
        break;
    }
	}
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

/**
 * Left pad, with blanks
 *
 * @param s
 * @param len
 * @return
 */
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

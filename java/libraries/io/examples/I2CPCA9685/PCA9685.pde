import processing.io.I2C;

// PCA9685 is a 16-channel servo driver
// datasheet: https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf
// code contributed by @OlivierLD

public class PCA9685 extends I2C {
  public final static int PCA9685_ADDRESS = 0x40;

  public final static int SUBADR1 = 0x02;
  public final static int SUBADR2 = 0x03;
  public final static int SUBADR3 = 0x04;
  public final static int MODE1 = 0x00;
  public final static int PRESCALE = 0xFE;
  public final static int LED0_ON_L = 0x06;
  public final static int LED0_ON_H = 0x07;
  public final static int LED0_OFF_L = 0x08;
  public final static int LED0_OFF_H = 0x09;
  public final static int ALL_LED_ON_L = 0xFA;
  public final static int ALL_LED_ON_H = 0xFB;
  public final static int ALL_LED_OFF_L = 0xFC;
  public final static int ALL_LED_OFF_H = 0xFD;

  private boolean verbose = "true".equals(System.getProperty("pca9685.verbose"));
  private int freq = 60;

  public final static String DEFAULT_BUS = "i2c-1";

  private int address;

  public PCA9685() {
    this(DEFAULT_BUS, PCA9685_ADDRESS);
  }
  public PCA9685(int addr) {
    this(DEFAULT_BUS, addr);
  }
  public PCA9685(String bus) {
    this(bus, PCA9685_ADDRESS);
  }
  public PCA9685(String bus, int address) {
    super(bus);
    this.address = address;

    String[] deviceList = I2C.list();
    if (verbose) {
      StringBuffer sb = new StringBuffer();
      for (String device : deviceList) {
        sb.append((sb.length() > 0 ? ", " : "") + device);
      }
      println(String.format("Device list: %s", sb.toString()));
      println(String.format("Bus %s, address 0x%02X", bus, address));
    }

    // Reseting
    command(MODE1, (byte) 0x00);
  }

  /**
   * @param freq 40..1000
   */
  public void setPWMFreq(int freq) {
    this.freq = freq;
    float preScaleVal = 25000000.0f; // 25MHz
    preScaleVal /= 4096.0;           // 4096: 12-bit
    preScaleVal /= freq;
    preScaleVal -= 1.0;
    if (verbose) {
      System.out.println("Setting PWM frequency to " + freq + " Hz");
      System.out.println("Estimated pre-scale: " + preScaleVal);
    }
    double preScale = Math.floor(preScaleVal + 0.5);
    if (verbose) {
      System.out.println("Final pre-scale: " + preScale);
    }

    byte oldmode = (byte) readbyte(MODE1);
    byte newmode = (byte) ((oldmode & 0x7F) | 0x10); // sleep
    command(MODE1, newmode);               // go to sleep
    command(PRESCALE, (byte) (Math.floor(preScale)));
    command(MODE1, oldmode);
    delay(5);
    command(MODE1, (byte) (oldmode | 0x80));
  }

  /**
   * @param channel 0..15
   * @param on      0..4095 (2^12 positions)
   * @param off     0..4095 (2^12 positions)
   */
  public void setPWM(int channel, int on, int off) throws IllegalArgumentException {
    if (channel < 0 || channel > 15) {
      throw new IllegalArgumentException("Channel must be in [0, 15]");
    }
    if (on < 0 || on > 4095) {
      throw new IllegalArgumentException("On must be in [0, 4095]");
    }
    if (off < 0 || off > 4095) {
      throw new IllegalArgumentException("Off must be in [0, 4095]");
    }
    if (on > off) {
      throw new IllegalArgumentException("Off must be greater than On");
    }
    command(LED0_ON_L + 4 * channel, (byte) (on & 0xFF));
    command(LED0_ON_H + 4 * channel, (byte) (on >> 8));
    command(LED0_OFF_L + 4 * channel, (byte) (off & 0xFF));
    command(LED0_OFF_H + 4 * channel, (byte) (off >> 8));
  }

  /**
   * @param channel 0..15
   * @param pulseMS in ms.
   */
  public void setServoPulse(int channel, float pulseMS) {
    double pulseLength = 1000000; // 1s = 1,000,000 us per pulse. "us" is to be read "micro (mu) sec".
    pulseLength /= this.freq;  // 40..1000 Hz
    pulseLength /= 4096;       // 12 bits of resolution
    int pulse = (int) (pulseMS * 1000);
    pulse /= pulseLength;
    if (verbose) {
      System.out.println(pulseLength + " us per bit, pulse:" + pulse);
    }
    this.setPWM(channel, 0, pulse);
  }

  private byte readbyte(int register) {
    super.beginTransmission(this.address);
    super.write(register);
    byte[] ba = super.read(1);
    super.endTransmission();
    return (byte)(ba[0] & 0xFF);
  }

  private void command(int reg, byte val) {
    super.beginTransmission(this.address);
    super.write(reg);
    super.write(val);
    super.endTransmission();
  }
}

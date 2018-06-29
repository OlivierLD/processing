import processing.io.I2C;

// HMC5883L is compass/magnetometer
// datasheet: https://cdn-shop.adafruit.com/datasheets/HMC5883L_3-Axis_Digital_Compass_IC.pdf
// code contributed by @OlivierLD

class HMC5883L extends I2C {
	public final static int HMC5883L_ADDRESS = 0x1E;

	public final static int HMC5883L_REGISTER_MR_REG_M  = 0x02;
	public final static int HMC5883L_REGISTER_OUT_X_H_M = 0x03;

	private final static float SCALE = 0.92F;

	private byte[] magData;

  private boolean verbose    = "true".equals(System.getProperty("hmc5883l.verbose", "false"));
  private boolean verboseRaw = "true".equals(System.getProperty("hmc5883l.verbose.raw", "false"));
  private boolean verboseMag = "true".equals(System.getProperty("hmc5883l.verbose.mag", "false"));

	private double pitch = 0D, roll = 0D, heading = 0D;

	private int freq = 60;

	public final static String DEFAULT_BUS = "i2c-1";

	private int address;

	public HMC5883L() {
		this(DEFAULT_BUS, HMC5883L_ADDRESS);
	}
	public HMC5883L(int addr) {
		this(DEFAULT_BUS, addr);
	}
	public HMC5883L(String bus) {
		this(bus, HMC5883L_ADDRESS);
	}
	public HMC5883L(String bus, int address) {
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
    command(HMC5883L_REGISTER_MR_REG_M, (byte) 0x00);
	}

  private void setPitch(double pitch) {
    this.pitch = pitch;
  }

  private void setRoll(double roll) {
    this.roll = roll;
  }

  private void setHeading(double heading) {
    this.heading = heading;
  }

  public double getPitch() {
    return this.pitch;
  }

  public double getRoll() {
    return this.roll;
  }

  public double getHeading() {
    return this.heading;
  }

  private void read() {
    magData = new byte[6];

    double magX = 0, magY = 0, magZ = 0;

    // Request magnetometer measurements.
    magData = readMagData();
    int r = magData.length;
    if (r != 6) {
      System.out.println("Error reading mag data, < 6 bytes");
    } else if (verboseMag) {
      dumpBytes(magData, 6);
    }
    // Mag raw data. !!! Warning !!! Order here is X, Z, Y
    magX = mag16(magData, 0) * SCALE;
    magZ = mag16(magData, 2) * SCALE; // Yes, Z
    magY = mag16(magData, 4) * SCALE; // Then Y

    heading = (float) Math.toDegrees(Math.atan2((double) magY, (double) magX));
    while (heading < 0) {
      heading += 360f;
    }
    setHeading(heading);

    pitch = Math.toDegrees(Math.atan2((double) magY, (double) magZ)); // See how it's done in LSM303...
    setPitch(pitch);
    roll = Math.toDegrees(Math.atan2((double) magX, (double) magZ));
    setRoll(roll);
//  if (verboseMag) {
//    System.out.println(String.format("Raw(int)Mag XYZ %d %d %d (0x%04X, 0x%04X, 0x%04X), HDG:%f", magX, magY, magZ, magX & 0xFFFF, magY & 0xFFFF, magZ & 0xFFFF, heading));
//  }
    if (verboseRaw) {
      System.out.println(String.format("RawMag (XYZ) (%d, %d, %d)", magX, magY, magZ));
    }

    if (verbose) {
      System.out.println(String.format(
          "heading: %f (mag), pitch: %f, roll: %f", heading, pitch, roll));
    }
  }

  private int mag16(byte[] list, int idx) {
    int n = ((list[idx] & 0xFF) << 8) | (list[idx + 1] & 0xFF); // High, low bytes
    return (n < 32768 ? n : n - 65536);                         // 2's complement signed
  }

  private void dumpBytes(byte[] ba, int len) {
    String str = String.format("%d bytes: ", len);
    for (int i = 0; i < len; i++) {
      str += (lpad(Integer.toHexString(ba[i] & 0xFF).toUpperCase(), 2, "0") + " ");
    }
    System.out.println(str);
  }

  private void command(int reg, byte val) {
    super.beginTransmission(this.address);
    super.write(reg);
    super.write(val);
    super.endTransmission();
  }
  
  byte[] readMagData() {
    this.beginTransmission(this.address);
    // command byte for reading the data
    this.write(HMC5883L_REGISTER_OUT_X_H_M);
    byte[] data = this.read(6);
    this.endTransmission();
    return data;
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
}

import processing.io.I2C;

/**
 * BMP180. Pressure (-> Altitude), Temperature.
 * <br/>
 * Big Endian
 * <br/>
 * I<sup><small>2</small></sup>C bus, Address 0x77.
 */
public class BMP180 extends I2C {

	public final static int BMP180_I2CADDRESS = 0x77;
	// Operating Modes
	public final static int BMP180_ULTRALOWPOWER = 0;
	public final static int BMP180_STANDARD = 1;
	public final static int BMP180_HIGHRES = 2;
	public final static int BMP180_ULTRAHIGHRES = 3;

	// BMP180 Registers
	public final static int BMP180_CAL_AC1 = 0xAA;  // R   Calibration data (16 bits)
	public final static int BMP180_CAL_AC2 = 0xAC;  // R   Calibration data (16 bits)
	public final static int BMP180_CAL_AC3 = 0xAE;  // R   Calibration data (16 bits)
	public final static int BMP180_CAL_AC4 = 0xB0;  // R   Calibration data (16 bits)
	public final static int BMP180_CAL_AC5 = 0xB2;  // R   Calibration data (16 bits)
	public final static int BMP180_CAL_AC6 = 0xB4;  // R   Calibration data (16 bits)
	public final static int BMP180_CAL_B1 = 0xB6;  // R   Calibration data (16 bits)
	public final static int BMP180_CAL_B2 = 0xB8;  // R   Calibration data (16 bits)
	public final static int BMP180_CAL_MB = 0xBA;  // R   Calibration data (16 bits)
	public final static int BMP180_CAL_MC = 0xBC;  // R   Calibration data (16 bits)
	public final static int BMP180_CAL_MD = 0xBE;  // R   Calibration data (16 bits)

	public final static int BMP180_CONTROL = 0xF4;
	public final static int BMP180_TEMPDATA = 0xF6;
	public final static int BMP180_PRESSUREDATA = 0xF6;
	public final static int BMP180_READTEMPCMD = 0x2E;
	public final static int BMP180_READPRESSURECMD = 0x34;

	private int cal_AC1 = 0;
	private int cal_AC2 = 0;
	private int cal_AC3 = 0;
	private int cal_AC4 = 0;
	private int cal_AC5 = 0;
	private int cal_AC6 = 0;
	private int cal_B1 = 0;
	private int cal_B2 = 0;
	private int cal_MB = 0;
	private int cal_MC = 0;
	private int cal_MD = 0;

	private boolean verbose = "true".equals(System.getProperty("bmp180.verbose", "false"));

	private int mode = BMP180_STANDARD;


	public final static int DEFAULT_ADDR = BMP180_I2CADDRESS;
	public final static String DEFAULT_BUS = "i2c-1";

	private int address;

	public BMP180() {
		this(DEFAULT_BUS, DEFAULT_ADDR);
	}
	public BMP180(int addr) {
		this(DEFAULT_BUS, addr);
	}
	public BMP180(String bus) {
		this(bus, DEFAULT_ADDR);
	}
	public BMP180(String bus, int address) {
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

		try {
			this.readCalibrationData();
			if (verbose) {
				this.showCalibrationData();
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	private void command(int reg, byte val) {
		super.beginTransmission(this.address);
		super.write(reg);
		super.write(val);
		super.endTransmission();
	}

	private void command(int reg, byte[] val) {
		super.beginTransmission(this.address);
		super.write(reg);
		super.write(val);
		super.endTransmission();
	}

	public void readCalibrationData() throws Exception {
		// Reads the calibration data from the IC
		cal_AC1 = readS16(BMP180_CAL_AC1);   // INT16
		cal_AC2 = readS16(BMP180_CAL_AC2);   // INT16
		cal_AC3 = readS16(BMP180_CAL_AC3);   // INT16
		cal_AC4 = readU16(BMP180_CAL_AC4);   // UINT16
		cal_AC5 = readU16(BMP180_CAL_AC5);   // UINT16
		cal_AC6 = readU16(BMP180_CAL_AC6);   // UINT16
		cal_B1 = readS16(BMP180_CAL_B1);    // INT16
		cal_B2 = readS16(BMP180_CAL_B2);    // INT16
		cal_MB = readS16(BMP180_CAL_MB);    // INT16
		cal_MC = readS16(BMP180_CAL_MC);    // INT16
		cal_MD = readS16(BMP180_CAL_MD);    // INT16
		if (verbose) {
			showCalibrationData();
		}
	}

	private void showCalibrationData() {
		// Displays the calibration values for debugging purposes
		System.out.println("DBG: AC1 = " + cal_AC1);
		System.out.println("DBG: AC2 = " + cal_AC2);
		System.out.println("DBG: AC3 = " + cal_AC3);
		System.out.println("DBG: AC4 = " + cal_AC4);
		System.out.println("DBG: AC5 = " + cal_AC5);
		System.out.println("DBG: AC6 = " + cal_AC6);
		System.out.println("DBG: B1  = " + cal_B1);
		System.out.println("DBG: B2  = " + cal_B2);
		System.out.println("DBG: MB  = " + cal_MB);
		System.out.println("DBG: MC  = " + cal_MC);
		System.out.println("DBG: MD  = " + cal_MD);
	}

	public int readRawTemp() throws Exception {
		// Reads the raw (uncompensated) temperature from the sensor
		this.command(BMP180_CONTROL, (byte) BMP180_READTEMPCMD);
		delay(5);  // Wait 5ms
		int raw = readU16(BMP180_TEMPDATA);
		if (verbose) {
			System.out.println("DBG: Raw Temp: " + (raw & 0xFFFF) + ", " + raw);
		}
		return raw;
	}

	public int readRawPressure() throws Exception {
		// Reads the raw (uncompensated) pressure level from the sensor
		this.command(BMP180_CONTROL, (byte) (BMP180_READPRESSURECMD + (this.mode << 6)));
		if (this.mode == BMP180_ULTRALOWPOWER) {
			delay(5);
		} else if (this.mode == BMP180_HIGHRES) {
			delay(14);
		} else if (this.mode == BMP180_ULTRAHIGHRES) {
			delay(26);
		} else {
			delay(8);
		}
		super.beginTransmission(this.address);
		int msb = this.readU8(BMP180_PRESSUREDATA);
		int lsb = this.readU8(BMP180_PRESSUREDATA + 1);
		int xlsb = this.readU8(BMP180_PRESSUREDATA + 2);
		super.endTransmission();
		int raw = ((msb << 16) + (lsb << 8) + xlsb) >> (8 - this.mode);
		if (verbose) {
			System.out.println("DBG: Raw Pressure: " + (raw & 0xFFFF) + ", " + raw);
		}
		return raw;
	}

	public float readTemperature() throws Exception {
		// Gets the compensated temperature in degrees celcius
		int UT = 0;
		int X1 = 0;
		int X2 = 0;
		int B5 = 0;
		float temp = 0.0f;

		// Read raw temp before aligning it with the calibration values
		UT = this.readRawTemp();
		X1 = ((UT - this.cal_AC6) * this.cal_AC5) >> 15;
		X2 = (this.cal_MC << 11) / (X1 + this.cal_MD);
		B5 = X1 + X2;
		temp = ((B5 + 8) >> 4) / 10.0f;
		if (verbose) {
			System.out.println("DBG: Calibrated temperature = " + temp + " C");
		}
		return temp;
	}

	public float readPressure() throws Exception {
		// Gets the compensated pressure in pascal
		int UT = 0;
		int UP = 0;
		int B3 = 0;
		int B5 = 0;
		int B6 = 0;
		int X1 = 0;
		int X2 = 0;
		int X3 = 0;
		int p = 0;
		int B4 = 0;
		int B7 = 0;

		UT = this.readRawTemp();
		UP = this.readRawPressure();

		// You can use the datasheet values to test the conversion results
		// boolean dataSheetValues = true;
		boolean dataSheetValues = false;

		if (dataSheetValues) {
			UT = 27898;
			UP = 23843;
			this.cal_AC6 = 23153;
			this.cal_AC5 = 32757;
			this.cal_MB = -32768;
			this.cal_MC = -8711;
			this.cal_MD = 2868;
			this.cal_B1 = 6190;
			this.cal_B2 = 4;
			this.cal_AC3 = -14383;
			this.cal_AC2 = -72;
			this.cal_AC1 = 408;
			this.cal_AC4 = 32741;
			this.mode = BMP180_ULTRALOWPOWER;
			if (verbose) {
				this.showCalibrationData();
			}
		}
		// True Temperature Calculations
		X1 = (int) ((UT - this.cal_AC6) * this.cal_AC5) >> 15;
		X2 = (this.cal_MC << 11) / (X1 + this.cal_MD);
		B5 = X1 + X2;
		if (verbose) {
			System.out.println("DBG: X1 = " + X1);
			System.out.println("DBG: X2 = " + X2);
			System.out.println("DBG: B5 = " + B5);
			System.out.println("DBG: True Temperature = " + (((B5 + 8) >> 4) / 10.0) + " C");
		}
		// Pressure Calculations
		B6 = B5 - 4000;
		X1 = (this.cal_B2 * (B6 * B6) >> 12) >> 11;
		X2 = (this.cal_AC2 * B6) >> 11;
		X3 = X1 + X2;
		B3 = (((this.cal_AC1 * 4 + X3) << this.mode) + 2) / 4;
		if (verbose) {
			System.out.println("DBG: B6 = " + B6);
			System.out.println("DBG: X1 = " + X1);
			System.out.println("DBG: X2 = " + X2);
			System.out.println("DBG: X3 = " + X3);
			System.out.println("DBG: B3 = " + B3);
		}
		X1 = (this.cal_AC3 * B6) >> 13;
		X2 = (this.cal_B1 * ((B6 * B6) >> 12)) >> 16;
		X3 = ((X1 + X2) + 2) >> 2;
		B4 = (this.cal_AC4 * (X3 + 32768)) >> 15;
		B7 = (UP - B3) * (50000 >> this.mode);
		if (verbose) {
			System.out.println("DBG: X1 = " + X1);
			System.out.println("DBG: X2 = " + X2);
			System.out.println("DBG: X3 = " + X3);
			System.out.println("DBG: B4 = " + B4);
			System.out.println("DBG: B7 = " + B7);
		}
		if (B7 < 0x80000000) {
			p = (B7 * 2) / B4;
		} else {
			p = (B7 / B4) * 2;
		}
		if (verbose) {
			System.out.println("DBG: X1 = " + X1);
		}
		X1 = (p >> 8) * (p >> 8);
		X1 = (X1 * 3038) >> 16;
		X2 = (-7357 * p) >> 16;
		if (verbose) {
			System.out.println("DBG: p  = " + p);
			System.out.println("DBG: X1 = " + X1);
			System.out.println("DBG: X2 = " + X2);
		}
		p = p + ((X1 + X2 + 3791) >> 4);
		if (verbose) {
			System.out.println("DBG: Pressure = " + p + " Pa");
		}
		return p;
	}

	private int standardSeaLevelPressure = 101_325; // in Pa, eq to 1013.25 hPa

	public void setStandardSeaLevelPressure(int standardSeaLevelPressure) {
		this.standardSeaLevelPressure = standardSeaLevelPressure;
	}

	public double readAltitude() throws Exception {
		// Calculates the altitude in meters
		double altitude = 0.0;
		float pressure = readPressure();
		altitude = 44330.0 * (1.0 - Math.pow(pressure / standardSeaLevelPressure, 0.1903));
		if (verbose) {
			System.out.println("DBG: Altitude = " + altitude);
		}
		return altitude;
	}

	/**
	 * Read an Unsigned 16 bit word from register.
	 * @param register
	 * @return
	 */
	private int readU16(int register) {
		super.beginTransmission(this.address);
		super.write((byte)register);
		byte[] ba = super.read(2);
		super.endTransmission();
		return ((ba[0] & 0xFF) << 8) + (ba[1] & 0xFF); // Big Endian
	}

	/**
	 * Read a Signed 16 bit word from register.
	 * @param register
	 * @return
	 */
	private int readS16(int register) {
		super.beginTransmission(this.address);
		super.write((byte)register);
		byte[] ba = super.read(2);
		super.endTransmission();

		int lo = ba[1] & 0xFF;
		int hi = ba[0] & 0xFF;
		if (hi > 127)
			hi -= 256;
		return (hi << 8) + lo; // Little Endian
	}

	/**
	 * Read an Unsigned byte from register.
	 * @param register
	 * @return
	 */
	private int readU8(int register) {
		super.beginTransmission(this.address);
		super.write(register);
		byte[] ba = super.read(1);
		super.endTransmission();
		return (int)(ba[0] & 0xFF);
	}

	/**
	 * Read a Signed byte from register.
	 * @param register
	 * @return
	 */
	private int readS8(int register) {
		int val = this.readU8(register);
		if (val > 127)
			val -= 256;
		return val;
	}

  void delay(long t) {
    try {
      Thread.sleep(t);
    } catch (InterruptedException ie) {
      // Absorb
    }
  }

  String rpad(String s, int len) {
    return rpad(s, len, " ");
  }

  String rpad(String s, int len, String pad) {
    String str = s;
    while (str.length() < len) {
      str += pad;
    }
    return str;
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
}

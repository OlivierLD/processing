import processing.io.I2C;

/**
 * BME280. Pressure (-> Altitude), Temperature, Humidity.
 * <br/>
 * Little Endian
 * <br/>
 * I<sup><small>2</small></sup>C bus, Address 0x77.
 */
public class BME280 extends I2C {

	public final static int BME280_I2CADDR = 0x77;

	// Operating Modes
	public final static int BME280_OSAMPLE_1  = 1;
	public final static int BME280_OSAMPLE_2  = 2;
	public final static int BME280_OSAMPLE_4  = 3;
	public final static int BME280_OSAMPLE_8  = 4;
	public final static int BME280_OSAMPLE_16 = 5;

	// BME280 Registers
	public final static int BME280_REGISTER_DIG_T1 = 0x88;  // Trimming parameter registers
	public final static int BME280_REGISTER_DIG_T2 = 0x8A;
	public final static int BME280_REGISTER_DIG_T3 = 0x8C;

	public final static int BME280_REGISTER_DIG_P1 = 0x8E;
	public final static int BME280_REGISTER_DIG_P2 = 0x90;
	public final static int BME280_REGISTER_DIG_P3 = 0x92;
	public final static int BME280_REGISTER_DIG_P4 = 0x94;
	public final static int BME280_REGISTER_DIG_P5 = 0x96;
	public final static int BME280_REGISTER_DIG_P6 = 0x98;
	public final static int BME280_REGISTER_DIG_P7 = 0x9A;
	public final static int BME280_REGISTER_DIG_P8 = 0x9C;
	public final static int BME280_REGISTER_DIG_P9 = 0x9E;

	public final static int BME280_REGISTER_DIG_H1 = 0xA1;
	public final static int BME280_REGISTER_DIG_H2 = 0xE1;
	public final static int BME280_REGISTER_DIG_H3 = 0xE3;
	public final static int BME280_REGISTER_DIG_H4 = 0xE4;
	public final static int BME280_REGISTER_DIG_H5 = 0xE5;
	public final static int BME280_REGISTER_DIG_H6 = 0xE6;
	public final static int BME280_REGISTER_DIG_H7 = 0xE7;

	public final static int BME280_REGISTER_CHIPID = 0xD0;
	public final static int BME280_REGISTER_VERSION = 0xD1;
	public final static int BME280_REGISTER_SOFTRESET = 0xE0;

	public final static int BME280_REGISTER_CONTROL_HUM = 0xF2;
	public final static int BME280_REGISTER_CONTROL = 0xF4;
	public final static int BME280_REGISTER_CONFIG = 0xF5;
	public final static int BME280_REGISTER_PRESSURE_DATA = 0xF7;
	public final static int BME280_REGISTER_TEMP_DATA = 0xFA;
	public final static int BME280_REGISTER_HUMIDITY_DATA = 0xFD;

	private int dig_T1 = 0;
	private int dig_T2 = 0;
	private int dig_T3 = 0;

	private int dig_P1 = 0;
	private int dig_P2 = 0;
	private int dig_P3 = 0;
	private int dig_P4 = 0;
	private int dig_P5 = 0;
	private int dig_P6 = 0;
	private int dig_P7 = 0;
	private int dig_P8 = 0;
	private int dig_P9 = 0;

	private int dig_H1 = 0;
	private int dig_H2 = 0;
	private int dig_H3 = 0;
	private int dig_H4 = 0;
	private int dig_H5 = 0;
	private int dig_H6 = 0;

	private float tFine = 0F;

	public final static int DEFAULT_ADDR = BME280_I2CADDR;
	public final static String DEFAULT_BUS = "i2c-1";

	private int address;
	private int mode = BME280_OSAMPLE_8;

	boolean verbose = "true".equals(System.getProperty("bme280.verbose", "false"));

	public BME280() {
		this(DEFAULT_BUS, DEFAULT_ADDR);
	}
	public BME280(int addr) {
		this(DEFAULT_BUS, addr);
	}
	public BME280(String bus) {
		this(bus, DEFAULT_ADDR);
	}
	public BME280(String bus, int address) {
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

		// Soft reset
		this.command(BME280_REGISTER_SOFTRESET, (byte)0xB6);
		// Wait for the chip to wake up
		delay(300L);

		try {
			this.readCalibrationData();
			if (verbose) {
				this.showCalibrationData();
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}

		this.command(BME280_REGISTER_CONTROL, (byte)0x3F);
		tFine = 0.0f;
	}

	public void readCalibrationData() throws Exception {
		// Reads the calibration data from the IC
		dig_T1 = readU16LE(BME280_REGISTER_DIG_T1);
		dig_T2 = readS16LE(BME280_REGISTER_DIG_T2);
		dig_T3 = readS16LE(BME280_REGISTER_DIG_T3);

		dig_P1 = readU16LE(BME280_REGISTER_DIG_P1);
		dig_P2 = readS16LE(BME280_REGISTER_DIG_P2);
		dig_P3 = readS16LE(BME280_REGISTER_DIG_P3);
		dig_P4 = readS16LE(BME280_REGISTER_DIG_P4);
		dig_P5 = readS16LE(BME280_REGISTER_DIG_P5);
		dig_P6 = readS16LE(BME280_REGISTER_DIG_P6);
		dig_P7 = readS16LE(BME280_REGISTER_DIG_P7);
		dig_P8 = readS16LE(BME280_REGISTER_DIG_P8);
		dig_P9 = readS16LE(BME280_REGISTER_DIG_P9);

		dig_H1 = this.readU8(BME280_REGISTER_DIG_H1);
		dig_H2 = readS16LE(BME280_REGISTER_DIG_H2);
		dig_H3 = this.readU8(BME280_REGISTER_DIG_H3);
		dig_H6 = readS8(BME280_REGISTER_DIG_H7);

		int h4 = readS8(BME280_REGISTER_DIG_H4);
		h4 = (h4 << 24) >> 20;
		dig_H4 = h4 | (readU8(BME280_REGISTER_DIG_H5) & 0x0F);

		int h5 = readS8(BME280_REGISTER_DIG_H6);
		h5 = (h5 << 24) >> 20;
		dig_H5 = h5 | (readU8(BME280_REGISTER_DIG_H5) >> 4 & 0x0F);
	}

	private String displayRegister(int reg) {
		return String.format("0x%s (%d)", lpad(Integer.toHexString(reg & 0xFFFF).toUpperCase(), 4, "0"), reg);
	}

	private void showCalibrationData() {
		// Displays the calibration values for debugging purposes
		println("======================");
		println("DBG: T1 = " + displayRegister(dig_T1));
		println("DBG: T2 = " + displayRegister(dig_T2));
		println("DBG: T3 = " + displayRegister(dig_T3));
		println("----------------------");
		println("DBG: P1 = " + displayRegister(dig_P1));
		println("DBG: P2 = " + displayRegister(dig_P2));
		println("DBG: P3 = " + displayRegister(dig_P3));
		println("DBG: P4 = " + displayRegister(dig_P4));
		println("DBG: P5 = " + displayRegister(dig_P5));
		println("DBG: P6 = " + displayRegister(dig_P6));
		println("DBG: P7 = " + displayRegister(dig_P7));
		println("DBG: P8 = " + displayRegister(dig_P8));
		println("DBG: P9 = " + displayRegister(dig_P9));
		println("----------------------");
		println("DBG: H1 = " + displayRegister(dig_H1));
		println("DBG: H2 = " + displayRegister(dig_H2));
		println("DBG: H3 = " + displayRegister(dig_H3));
		println("DBG: H4 = " + displayRegister(dig_H4));
		println("DBG: H5 = " + displayRegister(dig_H5));
		println("DBG: H6 = " + displayRegister(dig_H6));
		println("======================");
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

	private int readRawTemp() throws Exception {
		// Reads the raw (uncompensated) temperature from the sensor
		int meas = mode;
		if (verbose) {
			println(String.format("readRawTemp: 1 - meas=%d", meas));
		}
		this.command(BME280_REGISTER_CONTROL_HUM, (byte) meas); // HUM ?
		meas = mode << 5 | mode << 2 | 1;
		if (verbose) {
			println(String.format("readRawTemp: 2 - meas=%d", meas));
		}
		this.command(BME280_REGISTER_CONTROL, (byte) meas);

		double sleepTime = 0.00125 + 0.0023 * (1 << mode);
		sleepTime = sleepTime + 0.0023 * (1 << mode) + 0.000575;
		sleepTime = sleepTime + 0.0023 * (1 << mode) + 0.000575;
		delay(Math.round(sleepTime * 1000L));
		int msb = this.readU8(BME280_REGISTER_TEMP_DATA);
		int lsb = this.readU8(BME280_REGISTER_TEMP_DATA + 1);
		int xlsb = this.readU8(BME280_REGISTER_TEMP_DATA + 2);
		int raw = ((msb << 16) | (lsb << 8) | xlsb) >> 4;
		if (verbose) {
			println("DBG: Raw Temp: " + (raw & 0xFFFF) + ", " + raw + String.format(", msb: 0x%04X lsb: 0x%04X xlsb: 0x%04X", msb, lsb, xlsb));
		}
		return raw;
	}

	private int readRawPressure() throws Exception {
		// Reads the raw (uncompensated) pressure level from the sensor
		int msb = this.readU8(BME280_REGISTER_PRESSURE_DATA);
		int lsb = this.readU8(BME280_REGISTER_PRESSURE_DATA + 1);
		int xlsb = this.readU8(BME280_REGISTER_PRESSURE_DATA + 2);
		int raw = ((msb << 16) | (lsb << 8) | xlsb) >> 4;
		if (verbose) {
			println("DBG: Raw Press: " + (raw & 0xFFFF) + ", " + raw + String.format(", msb: 0x%04X lsb: 0x%04X xlsb: 0x%04X", msb, lsb, xlsb));
		}
		return raw;
	}

	private int readRawHumidity() throws Exception {
		int msb = this.readU8(BME280_REGISTER_HUMIDITY_DATA);
		int lsb = this.readU8(BME280_REGISTER_HUMIDITY_DATA + 1);
		int raw = (msb << 8) | lsb;
		return raw;
	}

	protected float readTemperature() throws Exception {
		// Gets the compensated temperature in degrees celcius
		float UT = readRawTemp();
		float var1 = 0;
		float var2 = 0;
		float temp = 0.0f;

		// Read raw temp before aligning it with the calibration values
		var1 = (UT / 16384.0f - dig_T1 / 1024.0f) * (float) dig_T2;
		var2 = ((UT / 131072.0f - dig_T1 / 8192.0f) * (UT / 131072.0f - dig_T1 / 8192.0f)) * (float) dig_T3;
		tFine = (int) (var1 + var2);
		temp = (var1 + var2) / 5120.0f;
		if (verbose) {
			println("DBG: Calibrated temperature = " + temp + " C");
		}
		return temp;
	}

	protected float readPressure() throws Exception {
		// Gets the compensated pressure in pascal
		int adc = readRawPressure();
		if (verbose) {
			println("ADC:" + adc + ", tFine:" + tFine);
		}
		float var1 = (tFine / 2.0f) - 64000.0f;
		float var2 = var1 * var1 * (dig_P6 / 32768.0f);
		var2 = var2 + var1 * dig_P5 * 2.0f;
		var2 = (var2 / 4.0f) + (dig_P4 * 65536.0f);
		var1 = (dig_P3 * var1 * var1 / 524288.0f + dig_P2 * var1) / 524288.0f;
		var1 = (1.0f + var1 / 32768.0f) * dig_P1;
		if (var1 == 0f) {
			return 0f;
    }
		float p = 1048576.0f - adc;
		p = ((p - var2 / 4096.0f) * 6250.0f) / var1;
		var1 = dig_P9 * p * p / 2147483648.0f;
		var2 = p * dig_P8 / 32768.0f;
		p = p + (var1 + var2 + dig_P7) / 16.0f;
		if (verbose) {
			println("DBG: Pressure = " + p + " Pa");
		}
		return p;
	}

	protected float readHumidity() throws Exception {
		int adc = readRawHumidity();
		float h = tFine - 76800.0f;
		h = (adc - (dig_H4 * 64.0f + dig_H5 / 16384.8f * h)) *
				(dig_H2 / 65536.0f * (1.0f + dig_H6 / 67108864.0f * h * (1.0f + dig_H3 / 67108864.0f * h)));
		h = h * (1.0f - dig_H1 * h / 524288.0f);
		if (h > 100) {
			h = 100;
		} else if (h < 0) {
			h = 0;
    }
		if (verbose) {
			println("DBG: Humidity = " + h);
		}
		return h;
	}

	private int standardSeaLevelPressure = 1013_25; // in Pascals. 1013.25 hPa

	public void setStandardSeaLevelPressure(int standardSeaLevelPressure) {
		this.standardSeaLevelPressure = standardSeaLevelPressure;
	}

	protected double readAltitude() throws Exception {
		// "Calculates the altitude in meters"
		double altitude = 0.0;
		float pressure = readPressure();
    if (standardSeaLevelPressure != 0) {
		  altitude = 44330.0 * (1.0 - Math.pow(pressure / standardSeaLevelPressure, 0.1903));
    }
		if (verbose) {
			println(String.format("DBG: Press: %f, PRMSL: %d, Altitude = %f", pressure, standardSeaLevelPressure, altitude));
		}
		return altitude;
	}

	/**
	 * Use this one if you are at the sea level.
	 * @return temperature, pressure, altitude and humidity
	 */
	public BME280Data getAllData() {
		return getAllData(null);
	}

	/**
	 * The order used to read the data is <strong>important!</strong>
	 *
	 * @param prmsl Pressure at Mean Sea Level, in Pa. Standard value is 101,325 Pa (1013.25 hPa, aka mb).
	 * @return temperature, pressure, altitude and humidity.
	 */
	public BME280Data getAllData(Float prmsl) {
		// 1.temperature, 2.pressure (analog to altitude), 3.humidity.
		float temp = 0f, press = 0f, alt = 0f, hum = 0f;
		try {
			temp = this.readTemperature();
		} catch (Exception ex) {
			System.err.println(ex.getMessage());
			ex.printStackTrace();
		}
		try {
			press = this.readPressure();
		} catch (Exception ex) {
			System.err.println(ex.getMessage());
			ex.printStackTrace();
		}
		this.setStandardSeaLevelPressure((prmsl == null) ? (int) press : prmsl.intValue());
		try {
			alt = (float)this.readAltitude();
		} catch (Exception ex) {
			System.err.println(ex.getMessage());
			ex.printStackTrace();
		}
		try {
			hum = this.readHumidity();
		} catch (Exception ex) {
			System.err.println(ex.getMessage());
			ex.printStackTrace();
		}
		return new BME280Data(temp, press, alt, hum);
	}

	/**
	 * Read a 16 bit word, unsigned, Little Endian.
	 * @param register the one to read
	 * @return the int value of the read 16 bit word
	 */
	private int readU16LE(int register) {
		super.beginTransmission(this.address);
		super.write((byte)register);
		byte[] ba = super.read(2);
		super.endTransmission();
		return ((ba[1] & 0xFF) << 8) + (ba[0] & 0xFF); // Little Endian
	}

	/**
	 * Read a 16 bit word, signed, Little Endian.
	 * @param register the one to read
	 * @return the int value of the read 16 bit word
	 */
	private int readS16LE(int register) {
		super.beginTransmission(this.address);
		super.write((byte)register);
		byte[] ba = super.read(2);
		super.endTransmission();

		int lo = ba[0] & 0xFF;
		int hi = ba[1] & 0xFF;
		if (hi > 127)
			hi -= 256;
		return (hi << 8) + lo; // Little Endian
	}

	/**
	 * read unsigned byte from register
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
	 * read signed byte from register
	 * @param register
	 * @return
	 */
	int readS8(int register) {
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

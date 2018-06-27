import java.util.*;
import processing.io.*;

/**
 * Note: The GPIO.pinMode is a demanding operation.
 * Should/could be improved, there are some Thread.sleep that make the flip from input and output
 * longer than it should. Will look into it.
 *
 * STH10, Temperature, Humidity.
 * Mesh-protected Weather-proof Temperature/Humidity Sensor - SHT10
 * https://www.adafruit.com/product/1298
 *
       +-----+-----+--------------+-----++-----+--------------+-----+-----+
       | BCM | wPi | Name         |  Physical  |         Name | wPi | BCM |
       +-----+-----+--------------+-----++-----+--------------+-----+-----+
       |     |     | 3v3          | #01 || #02 |          5v0 |     |     |
       |  02 |  08 | SDA1         | #03 || #04 |          5v0 |     |     |
       |  03 |  09 | SCL1         | #05 || #06 |          GND |     |     |
       |  04 |  07 | GPCLK0       | #07 || #08 |    UART0_TXD | 15  | 14  |
       |     |     | GND          | #09 || #10 |    UART0_RXD | 16  | 15  |
       |  17 |  00 | GPIO_0       | #11 || #12 | PCM_CLK/PWM0 | 01  | 18  |  DEFAULT_DATA
       |  27 |  02 | GPIO_2       | #13 || #14 |          GND |     |     |
       |  22 |  03 | GPIO_3       | #15 || #16 |       GPIO_4 | 04  | 23  |  DEFAULT_CLOCK
       |     |     | 3v3          | #01 || #18 |       GPIO_5 | 05  | 24  |
       |  10 |  12 | SPI0_MOSI    | #19 || #20 |          GND |     |     |
       |  09 |  13 | SPI0_MISO    | #21 || #22 |       GPIO_6 | 06  | 25  |
       |  11 |  14 | SPI0_CLK     | #23 || #24 |   SPI0_CS0_N | 10  | 08  |
       |     |     | GND          | #25 || #26 |   SPI0_CS1_N | 11  | 07  |
       |     |  30 | SDA0         | #27 || #28 |         SCL0 | 31  |     |
       |  05 |  21 | GPCLK1       | #29 || #30 |          GND |     |     |
       |  06 |  22 | GPCLK2       | #31 || #32 |         PWM0 | 26  | 12  |
       |  13 |  23 | PWM1         | #33 || #34 |          GND |     |     |
       |  19 |  24 | PCM_FS/PWM1  | #35 || #36 |      GPIO_27 | 27  | 16  |
       |  26 |  25 | GPIO_25      | #37 || #38 |      PCM_DIN | 28  | 20  |
       |     |     | GND          | #39 || #40 |     PCM_DOUT | 29  | 21  |
       +-----+-----+--------------+-----++-----+--------------+-----+-----+
       | BCM | wPi | Name         |  Physical  |         Name | wPi | BCM |
       +-----+-----+--------------+-----++-----+--------------+-----+-----+
 *
 * Pin numbers for method of the GPIO class are BCM numbers.
 */
class STH10 {

  private boolean DEBUG = "true".equals(System.getProperty("sth10.verbose"));

  private long lastPlot = System.currentTimeMillis();
  private String previousOp = "none";

  private final static int DEFAULT_DATA_PIN = 18;
  private final static int DEFAULT_CLOCK_PIN = 23;

  private byte statusRegister = 0x0;

  private final static double
      D2_SO_C = 0.01,
      D1_VDD_C = -39.7,
      C1_SO = -2.0468,
      C2_SO = 0.0367,
      C3_SO = -0.0000015955,
      T1_S0 = 0.01,
      T2_SO = 0.00008;

  private int dataPin, clockPin;
  private boolean simulating = NativeInterface.isSimulated();

  public STH10() {
    this(DEFAULT_DATA_PIN, DEFAULT_CLOCK_PIN);
  }

  public STH10(int data, int clock) {

    this.dataPin = data;
    this.clockPin = clock;

    if ("true".equals(System.getProperty("gpio.verbose"))) {
      println(String.format("GPIO> Opening GPIO (%s)", this.getClass().getName()));
    }

    if (simulating) {
       if ("true".equals(System.getProperty("gpio.verbose"))) {
          println(String.format("GPIO> Will simulate (for %s)", this.getClass().getName()));
       }
    } else {
      GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
      GPIO.pinMode(this.clockPin, GPIO.OUTPUT);
      if (DEBUG) {
        println(String.format(">> Constructor >>\telapsed:\t%d\tlastOp was\t%s", elapsed("STH10 - pinMode"), previousOp));
      }
    }
    this.init();
  }

  void init() {
    if (DEBUG) {
      println(String.format(">> Init >>\telapsed:\t%d\tlastOp was\t%s", elapsed("init - 1"), previousOp));
    }
    this.resetConnection();
    byte mask = 0x0;
    if (DEBUG) {
      println(String.format(">> Init, writeStatusRegister, with mask %s >>\telapsed:\t%d\tlastOp was\t%s", lpad(Integer.toBinaryString(mask), 8, "0"), elapsed("init - 2"), previousOp));
    }
    this.writeStatusRegister(mask);
    if (DEBUG) {
      println("<< Init <<");
    }
  }

  public double readTemperature() {
    byte cmd = COMMANDS.get(TEMPERATURE_CMD);
    this.sendCommandSHT(cmd);
    int value = 0;
    if (!simulating) {
      value = this.readMeasurement();
      if (DEBUG) {
        println(String.format(">> Read temperature raw value %d, 0x%s\telapsed:\t%d\tlastOp was\t%s", value, lpad(Integer.toBinaryString(value), 16, "0"), elapsed("readTemperature - 1"), previousOp));
      }
      return (value * D2_SO_C) + (D1_VDD_C); // Celcius
    } else {
      return Simulators.TempSimulator.get();
    }
  }

  public double readHumidity() {
    return readHumidity(null);
  }

  public double readHumidity(Double temp) {
    double t;
    if (temp == null) {
      t = this.readTemperature();
    } else {
      t = temp;
    }
    byte cmd = COMMANDS.get(HUMIDITY_CMD);
    this.sendCommandSHT(cmd);
    int value = 0;
    if (!simulating) {
      value = this.readMeasurement();
      if (DEBUG) {
        println(String.format(">> Read humidity raw value %d, 0x%s\telapsed:\t%d\tlastOp was\t%s", value, lpad(Integer.toBinaryString(value), 16, "0"), elapsed("readHumidity - 1"), previousOp));
      }
      double linearHumidity = C1_SO + (C2_SO * value) + (C3_SO * Math.pow(value, 2));
      double humidity = ((t - 25) * (T1_S0 + (T2_SO * value)) + linearHumidity); // %
      return humidity;
    } else {
      return Simulators.HumSimulator.get();
    }
  }

  /**
   *
   * @return a 16 bit word.
   */
  private int readMeasurement() {
    int value = 0;
    // MSB
    byte msb = this.getByte();
    value = (msb << 8);
    if (DEBUG) {
      println(String.format(">>> After MSB: %s\telapsed:\t%d\tlastOp was\t%s", lpad(Integer.toBinaryString(value), 16, "0"), elapsed("readMeasurement - 1"), previousOp));
    }
    this.sendAck();
    // LSB
    byte lsb = this.getByte();
    value |= (lsb & 0xFF);
    if (DEBUG) {
      println(String.format(">>> After LSB: %s\telapsed:\t%d\tlastOp was\t%s", lpad(Integer.toBinaryString(value), 16, "0"), elapsed("readMeasurement - 2"), previousOp));
    }
    this.endTx();
    return (value);
  }

  void resetConnection() {
    GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
    GPIO.pinMode(this.clockPin, GPIO.OUTPUT);
    if (DEBUG) {
      println(String.format(">> resetConnection >>\telapsed:\t%d\tlastOp was\t%s", elapsed("resetConnection - pinMode"), previousOp));
    }

    this.flipPin(this.dataPin, GPIO.HIGH);
    for (int i = 0; i < 10; i++) {
      this.flipPin(this.clockPin, GPIO.HIGH);
      this.flipPin(this.clockPin, GPIO.LOW);
    }
  }

  void softReset() {
    byte cmd = COMMANDS.get(SOFT_RESET_CMD);
    this.sendCommandSHT(cmd, false);
    delay(15L, 0); // 15 ms
    this.statusRegister = 0x0;
  }

  /**
   * pin is BCM pin#
   * state is GPIO.LOW or GPIO.HIGH
   */
  void flipPin(int pin, int state) {
    if (DEBUG) {
      println(String.format(">> flipPin %d to %s\telapsed:\t%d\tlastOp was\t%s", pin, (state == GPIO.HIGH ? "HIGH" : "LOW"), elapsed("flipPin - 1"), previousOp));
    }
    if (!simulating) {
      GPIO.digitalWrite(pin, state);
      if (pin == this.clockPin) {
        if (DEBUG) {
          println(String.format("   >> Flipping CLK, delaying\telapsed:\t%d\tlastOp was\t%s", elapsed("flipPin - 2"), previousOp));
        }
        delay(0L, 100); // 0.1 * 1E-6 sec. 100 * 1E-9
      }
    }
    if (DEBUG) {
      println(String.format("-- pin is now %s\telapsed:\t%d\tlastOp was\t%s", (state == GPIO.HIGH ? "HIGH" : "LOW"), elapsed("flipPin - 3"), previousOp));
    }
  }

  void sendByte(byte data) {
    if (DEBUG) {
      println(String.format(">> sendByte %d [%s]\telapsed:\t%d\tlastOp was\t%s", data, lpad(Integer.toBinaryString(data), 8,"0"), elapsed("sendByte - 1"), previousOp));
    }
    if (!simulating) {
      GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
      GPIO.pinMode(this.clockPin, GPIO.OUTPUT);
      if (DEBUG) {
        println(String.format(">> sendByte >>\telapsed:\t%d\tlastOp was\t%s", elapsed("sendByte - pinMode"), previousOp));
      }
    }
    for (int i=0; i<8; i++) {
      int bit = data & (1 << (7 - i));
      if (DEBUG) {
        println(String.format("  -- Bit #%d, %d, %s\telapsed:\t%d\tlastOp was\t%s", (i + 1), bit, (bit == 0 ? "LOW" : "HIGH"), elapsed("sendByte - 2"), previousOp));
      }
      this.flipPin(this.dataPin, (bit == 0 ? GPIO.LOW : GPIO.HIGH));

      this.flipPin(this.clockPin, GPIO.HIGH);
      this.flipPin(this.clockPin, GPIO.LOW);
    }
    if (DEBUG) {
      println(String.format("<< sendByte << \telapsed:\t%d\tlastOp was\t%s", elapsed("sendByte - 3"), previousOp));
    }
  }

  byte getByte() {
    if (DEBUG) {
      println(String.format(">> getByte >>\telapsed:\t%d\tlastOp was\t%s", elapsed("getByte - 1"), previousOp));
    }
    byte b = 0x0;

    if (!simulating) {
      GPIO.pinMode(this.dataPin, GPIO.INPUT);
      GPIO.pinMode(this.clockPin, GPIO.OUTPUT);
      if (DEBUG) {
        println(String.format(">> getByte >>\telapsed:\t%d\tlastOp was\t%s", elapsed("getByte - pinMode"), previousOp));
      }

      for (int i = 0; i < 8; i++) {
        this.flipPin(this.clockPin, GPIO.HIGH);
        int state = GPIO.digitalRead(this.dataPin);
        if (state == GPIO.HIGH) {
          b |= (1 << (7 - i));
        }
        if (DEBUG) {
          println(String.format(" -- getting byte %d, byte is %s\telapsed:\t%d\tlastOp was\t%s", i, lpad(Integer.toBinaryString(b & 0x00FF), 8, "0"), elapsed("getByte - 2"), previousOp));
        }
        this.flipPin(this.clockPin, GPIO.LOW);
      }
    }
    if (DEBUG) {
      println(String.format("<< getByte %d 0b%s <<\telapsed:\t%d\tlastOp was\t%s", (b & 0x00FF), lpad(Integer.toBinaryString(b & 0x00FF), 8, "0"), elapsed("getByte - 3"), previousOp));
    }
    return (byte)(b & 0x00FF);
  }

  void startTx() {
    if (DEBUG) {
      println(String.format(">> startTx >>\telapsed:\t%d\tlastOp was\t%s", elapsed("startTx - 1"), previousOp));
    }
    if (!simulating) {
      GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
      GPIO.pinMode(this.clockPin, GPIO.OUTPUT);
      if (DEBUG) {
        println(String.format(">> startTx >>\telapsed:\t%d\tlastOp was\t%s", elapsed("startTx - pinMode"), previousOp));
      }

      this.flipPin(this.dataPin, GPIO.HIGH);
      this.flipPin(this.clockPin, GPIO.HIGH);

      this.flipPin(this.dataPin, GPIO.LOW);
      this.flipPin(this.clockPin, GPIO.LOW);

      this.flipPin(this.clockPin, GPIO.HIGH); // Clock first
      this.flipPin(this.dataPin, GPIO.HIGH);  // Data 2nd

      this.flipPin(this.clockPin, GPIO.LOW);
    }
    if (DEBUG) {
      println(String.format("<< startTx <<\telapsed:\t%d\tlastOp was\t%s", elapsed("startTx - 2"), previousOp));
    }
  }

  void endTx() {
    if (DEBUG) {
      println(String.format(">> endTx >>\telapsed:\t%d\tlastOp was\t%s", elapsed("endTx - 1"), previousOp));
    }
    if (!simulating) {
      GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
      GPIO.pinMode(this.clockPin, GPIO.OUTPUT);
      if (DEBUG) {
        println(String.format(">> endTx >>\telapsed:\t%d\tlastOp was\t%s", elapsed("endTx - pinMode"), previousOp));
      }

      this.flipPin(this.dataPin, GPIO.HIGH);
      this.flipPin(this.clockPin, GPIO.HIGH);

      this.flipPin(this.clockPin, GPIO.LOW);
    }
    if (DEBUG) {
      println(String.format("<< endTx <<\telapsed:\t%d\tlastOp was\t%s", elapsed("endTx - 2"), previousOp));
    }
  }

  void writeStatusRegister(byte mask) {
    if (DEBUG) {
      println(String.format(">> writeStatusRegister, mask %d >>\telapsed:\t%d\tlastOp was\t%s", mask, elapsed("writeStatusRegister - 1"), previousOp));
    }
    byte cmd = COMMANDS.get(WRITE_STATUS_REGISTER_CMD);
    if (DEBUG) {
      println(String.format(">> writeStatusRegister, sendCommandSHT, cmd %d\telapsed:\t%d\tlastOp was\t%s", cmd, elapsed("writeStatusRegister - 2"), previousOp));
    }
    this.sendCommandSHT(cmd, false);
    this.sendByte(mask);
    if (DEBUG) {
      println(String.format(">> writeStatusRegister, getAck, cmd %d\telapsed:\t%d\tlastOp was\t%s", cmd, elapsed("writeStatusRegister - 3"), previousOp));
    }
    this.getAck(WRITE_STATUS_REGISTER_CMD);
    this.statusRegister = mask;
    if (DEBUG) {
      println(String.format("<< writeStatusRegister, mask %d <<\telapsed:\t%d\tlastOp was\t%s", mask, elapsed("writeStatusRegister - 4"), previousOp));
    }
  }

  void resetStatusRegister() {
    this.writeStatusRegister(COMMANDS.get(NO_OP_CMD));
  }

  void sendCommandSHT(byte command) {
    sendCommandSHT(command, true);
  }
  void sendCommandSHT(byte command, boolean measurement) {
    if (DEBUG) {
      println(String.format(">> sendCommandSHT %d >>\telapsed:\t%d\tlastOp was\t%s", command, elapsed("sendCommandSHT - 1"), previousOp));
    }
    if (!COMMANDS.containsValue(command)) {
      throw new RuntimeException(String.format("Command 0b%8s not found.", lpad(Integer.toBinaryString(command), 8, "0")));
    }
    String commandName= "";
    Iterator<String> iterator = COMMANDS.keySet().iterator();
    while (iterator.hasNext()) {
      String str = iterator.next();
      if (COMMANDS.get(str) == command) {
        commandName = str;
        break;
      }
    }

    this.startTx();
    this.sendByte(command);
    this.getAck(commandName);

    if (measurement) {
      if (DEBUG) {
        println(String.format(">> sendCommandSHT with measurement, %d\telapsed:\t%d\tlastOp was\t%s", command, elapsed("sendCommandSHT - 2"), previousOp));
      }
      int state = (!simulating ? GPIO.digitalRead(this.dataPin) : GPIO.HIGH);
      // SHT1x is taking measurement.
      if (state == GPIO.LOW) {
        throw new RuntimeException("SHT1x is not in the proper measurement state. DATA line is LOW.");
      }
      this.waitForResult();
    }
    if (DEBUG) {
      println(String.format("<< sendCommandSHT <<\telapsed:\t%d\tlastOp was\t%s", elapsed("sendCommandSHT - 3"), previousOp));
    }
  }

  void getAck(String commandName) {
    if (DEBUG) {
      println(String.format(">> getAck, command %s >>\telapsed:\t%d\tlastOp was\t%s", commandName, elapsed("getAck - 1"), previousOp));
      println(String.format(">> %d INPUT %d OUTPUT\telapsed:\t%d\tlastOp was\t%s", this.dataPin, this.clockPin, elapsed("getAck - 2"), previousOp));
    }
    if (!simulating) {
      GPIO.pinMode(this.dataPin, GPIO.INPUT);
      GPIO.pinMode(this.clockPin, GPIO.OUTPUT);
      if (DEBUG) {
        println(String.format(">> getAck >>\telapsed:\t%d\tlastOp was\t%s", elapsed("getAck - pinMode"), previousOp));
      }

      if (DEBUG) {
        println(String.format(">> getAck, flipping %d to HIGH\telapsed:\t%d\tlastOp was\t%s", this.clockPin, elapsed("getAck - 3"), previousOp));
      }
      this.flipPin(this.clockPin, GPIO.HIGH);
      if (DEBUG) {
        println(String.format(">> getAck, >>> getState %d\telapsed:\t%d\tlastOp was\t%s", this.clockPin, elapsed("getAck - 4"), previousOp));
      }
      int state = GPIO.digitalRead(this.dataPin);
      if (DEBUG) {
        println(String.format(">> getAck, getState %d = %s\telapsed:\t%d\tlastOp was\t%s", this.dataPin, (state == GPIO.HIGH ? "HIGH" : "LOW"), elapsed("getAck - 5"), previousOp));
      }
      if (state == GPIO.HIGH) {
        throw new RuntimeException(String.format("SHTx failed to properly receive ack after command [%s, 0b%8s]", commandName, lpad(Integer.toBinaryString(COMMANDS.get(commandName)), 8, "0")));
      }
      if (DEBUG) {
        println(String.format(">> getAck, flipping %d to LOW\telapsed:\t%d\tlastOp was\t%s", this.clockPin, elapsed("getAck - 6"), previousOp));
      }
      this.flipPin(this.clockPin, GPIO.LOW);
    }
    if (DEBUG) {
      println(String.format("<< getAck <<\telapsed:\t%d\tlastOp was\t%s", elapsed("getAck - 7"), previousOp));
    }
  }

  void sendAck() {
    if (!simulating) {
      GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
      GPIO.pinMode(this.clockPin, GPIO.OUTPUT);
      if (DEBUG) {
        println(String.format(">> sendAck >>\telapsed:\t%d\tlastOp was\t%s", elapsed("sendAck - pinMode"), previousOp));
      }

      this.flipPin(this.dataPin, GPIO.HIGH);
      this.flipPin(this.dataPin, GPIO.LOW);
      this.flipPin(this.clockPin, GPIO.HIGH);
      this.flipPin(this.clockPin, GPIO.LOW);
    }
  }

  private final static int NB_TRIES = 35;

  void waitForResult() {
    int state = GPIO.HIGH;
    if (!simulating) {
      GPIO.pinMode(this.dataPin, GPIO.INPUT);
      for (int t = 0; t < NB_TRIES; t++) {
        delay(10L, 0);
        state = GPIO.digitalRead(this.dataPin);
        if (state == GPIO.LOW) {
          if (DEBUG) {
            println(String.format(">> waitForResult completed iteration %d\telapsed:\t%d\tlastOp was\t%s", t, elapsed("waitForResult - 1"), previousOp));
          }
          break;
        } else {
          if (DEBUG) {
            println(String.format(">> waitForResult still waiting - iteration %d\telapsed:\t%d\tlastOp was\t%s", t, elapsed("waitForResult - 2"), previousOp));
          }
        }
      }
      if (state == GPIO.HIGH) {
        throw new RuntimeException("Sensor has not completed measurement within allocated time.");
      }
    }
  }

  /**
   * For debugging
   */
  long elapsed(String onOp) {
    long now = System.currentTimeMillis();
    long diff = now - lastPlot;
    lastPlot = now;
    previousOp = onOp;
    return diff;
  }

  void delay(long ms, int nano) {
    try {
      Thread.sleep(ms, nano);
    } catch (InterruptedException ie) {
      // Absorb
    }
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

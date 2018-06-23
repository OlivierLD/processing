import java.util.*;
import processing.io.*;

/**
 * STH10, Temperature, Humidity.
 *
       +-----+-----+--------------+-----++-----+--------------+-----+-----+
       | BCM | wPi | Name         |  Physical  |         Name | wPi | BCM |
       +-----+-----+--------------+-----++-----+--------------+-----+-----+
       |     |     | 3v3          | #01 || #02 |          5v0 |     |     |       
       |  02 |  08 | SDA1         | #03 || #04 |          5v0 |     |     |       
       |  03 |  09 | SCL1         | #05 || #06 |          GND |     |     |       
       |  04 |  07 | GPCLK0       | #07 || #08 |    UART0_TXD | 15  | 14  |       
       |     |     | GND          | #09 || #10 |    UART0_RXD | 16  | 15  |       
       |  17 |  00 | GPIO_0       | #11 || #12 | PCM_CLK/PWM0 | 01  | 18  |       
       |  27 |  02 | GPIO_2       | #13 || #14 |          GND |     |     |       
       |  22 |  03 | GPIO_3       | #15 || #16 |       GPIO_4 | 04  | 23  |       
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
public class STH10 {
  
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
  
  public STH10() {
    this(DEFAULT_DATA_PIN, DEFAULT_CLOCK_PIN);
  }
  
  public STH10(int data, int clock) {
    
    this.dataPin = data;
    this.clockPin = clock;
    
    GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
    GPIO.pinMode(this.clockPin, GPIO.OUTPUT);

    this.init();
  }
  
  void init() {
    this.resetConnection();
    byte mask = 0x0;
    this.writeStatusRegister(mask);
  }
  
  public double readTemperature() {
    byte cmd = COMMANDS.get(TEMPERATURE_CMD);
    this.sendCommandSHT(cmd);
    int value = 0;
    value = this.readMeasurement();
    return (value * D2_SO_C) + (D1_VDD_C); // Celcius
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
    value = this.readMeasurement();
    double linearHumidity = C1_SO + (C2_SO * value) + (C3_SO * Math.pow(value, 2));
    double humidity = ((t - 25) * (T1_S0 + (T2_SO * value)) + linearHumidity); // %
    return humidity;
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
    this.sendAck();
    // LSB
    byte lsb = this.getByte();
    value |= (lsb & 0xFF);
    this.endTx();
    return (value);
  }

  void resetConnection() {
    GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
    GPIO.pinMode(this.clockPin, GPIO.OUTPUT);

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
//  GPIO.digitalWrite(4, GPIO.LOW);
    GPIO.digitalWrite(pin, state);
    if (pin == this.clockPin) {
        delay(0L, 100); // 0.1 * 1E-6 sec. 100 * 1E-9
    }
  }

  void sendByte(byte data) {
    GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
    GPIO.pinMode(this.clockPin, GPIO.OUTPUT);

    for (int i=0; i<8; i++) {
      int bit = data & (1 << (7 - i));
      this.flipPin(this.dataPin, (bit == 0 ? GPIO.LOW : GPIO.HIGH));

      this.flipPin(this.clockPin, GPIO.HIGH);
      this.flipPin(this.clockPin, GPIO.LOW);
    }
  }

  byte getByte() {
    byte b = 0x0;

    GPIO.pinMode(this.dataPin, GPIO.INPUT);
    GPIO.pinMode(this.clockPin, GPIO.OUTPUT);

    for (int i = 0; i < 8; i++) {
      this.flipPin(this.clockPin, GPIO.HIGH);
      int state = GPIO.digitalRead(this.dataPin);
      if (state == GPIO.HIGH) {
        b |= (1 << (7 - i));
      }
      this.flipPin(this.clockPin, GPIO.LOW);
    }
    return (byte)(b & 0x00FF);
  }

  void startTx() {
    GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
    GPIO.pinMode(this.clockPin, GPIO.OUTPUT);

    this.flipPin(this.dataPin, GPIO.HIGH);
    this.flipPin(this.clockPin, GPIO.HIGH);

    this.flipPin(this.dataPin, GPIO.LOW);
    this.flipPin(this.clockPin, GPIO.LOW);

    this.flipPin(this.clockPin, GPIO.HIGH); // Clock first
    this.flipPin(this.dataPin, GPIO.HIGH);  // Data 2nd

    this.flipPin(this.clockPin, GPIO.LOW);
  }

  void endTx() {
    GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
    GPIO.pinMode(this.clockPin, GPIO.OUTPUT);

    this.flipPin(this.dataPin, GPIO.HIGH);
    this.flipPin(this.clockPin, GPIO.HIGH);

    this.flipPin(this.clockPin, GPIO.LOW);
  }

  void writeStatusRegister(byte mask) {
    byte cmd = COMMANDS.get(WRITE_STATUS_REGISTER_CMD);
    this.sendCommandSHT(cmd, false);
    //
    this.sendByte(mask);
    this.getAck(WRITE_STATUS_REGISTER_CMD);
    this.statusRegister = mask;
  }

  void resetStatusRegister() {
    this.writeStatusRegister(COMMANDS.get(NO_OP_CMD));
  }

  void sendCommandSHT(byte command) {
    sendCommandSHT(command, true);
  }
  void sendCommandSHT(byte command, boolean measurement) {
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
      int state = GPIO.digitalRead(this.dataPin); 
      // SHT1x is taking measurement.
      if (state == GPIO.LOW) {
        throw new RuntimeException("SHT1x is not in the proper measurement state. DATA line is LOW.");
      }
      this.waitForResult();
    }
  }

  void getAck(String commandName) {
    GPIO.pinMode(this.dataPin, GPIO.INPUT);
    GPIO.pinMode(this.clockPin, GPIO.OUTPUT);

    this.flipPin(this.clockPin, GPIO.HIGH);
    int state = GPIO.digitalRead(this.dataPin);
    if (state == GPIO.HIGH) {
      throw new RuntimeException(String.format("SHTx failed to properly receive ack after command [%s, 0b%8s]", commandName, lpad(Integer.toBinaryString(COMMANDS.get(commandName)), 8, "0")));
    }
    this.flipPin(this.clockPin, GPIO.LOW);
  }

  void sendAck() {
    GPIO.pinMode(this.dataPin, GPIO.OUTPUT);
    GPIO.pinMode(this.clockPin, GPIO.OUTPUT);

    this.flipPin(this.dataPin, GPIO.HIGH);
    this.flipPin(this.dataPin, GPIO.LOW);
    this.flipPin(this.clockPin, GPIO.HIGH);
    this.flipPin(this.clockPin, GPIO.LOW);
  }

  private final static int NB_TRIES = 35;

  void waitForResult() {
    int state = GPIO.HIGH;
    GPIO.pinMode(this.dataPin, GPIO.INPUT);
    for (int t = 0; t < NB_TRIES; t++) {
      delay(10L, 0);
      state = GPIO.digitalRead(this.dataPin);
      if (state == GPIO.LOW) {
        break;
      }
    }
    if (state == GPIO.HIGH) {
      throw new RuntimeException("Sensor has not completed measurement within allocated time.");
    }
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

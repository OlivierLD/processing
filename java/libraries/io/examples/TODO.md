## Hardware-IO examples to provide

- BME280, I<small><sup>2</sup></small>C sensor, Temperature, Pressure, Humidity. &#9989; Done
- BMP180, I<small><sup>2</sup></small>C sensor, Temperature, Pressure
- LSM303, I<small><sup>2</sup></small>C sensor, magnetometer, accelerometer
- STH10, temperature and humidity sensor
- Improved SSD1306 (I<small><sup>2</sup></small>C)  &#10140; WIP
- ADS 1x15, I<small><sup>2</sup></small>C ADC
- MeArm robotic arm, using an I<small><sup>2</sup></small>C PCA9685 Servo board.
- ...

#### Small Notes
On MacOS, in `build/build.xml`, change
```xml
  <property name="jdk.update" value="144" />
```
Other systems:
```xml
  <property name="jdk.update" value="172" />
```

### Wiring Diagrams
#### BME280
![BME280](./I2CBME280/RPi.BME280_bb.png)

#### SSD1306
![BME280](./I2CSSD1306/RPi.SSD1306_bb.png)

### Screenshots
#### BME280
![BME280](./I2CBME280/rpi.snapshot.png)

#### SSD1306
![On the PI](./I2CSSD1306/rpi.ssd1306.jpg)

![On Processing](./I2CSSD1306/screenshot.01.png)

![On Processing](./I2CSSD1306/screenshot.02.png)

![On Processing](./I2CSSD1306/screenshot.03.png)


---

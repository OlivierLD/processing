import processing.io.*;

ADS1x15 ads1015;

ICType ADC_TYPE = ICType.IC_ADS1015;

int gain = pgaADS1x15.ADS1015_REG_CONFIG_PGA_6_144V.meaning(); // +/- 6.144 V
int sps  = spsADS1015.ADS1015_REG_CONFIG_DR_250SPS.meaning();  // 250 Samples per Second

void setup() {
size(400, 400); 
  stroke(255);
  noFill();
  textSize(72); 
  ads1015 = new ADS1x15(I2C.list()[0], ADC_TYPE, ADS1x15.ADS1x15_ADDRESS);
}

// Values range from 0 to 3300 (3.3V), see the wiring. 
void draw() {
  background(0);
  stroke(255);
  try {
    float value = ads1015.readADCSingleEnded(Channels.CHANNEL_0, gain, sps);
    println(String.format("Value: %f, %.03f V", value, (value / 1000)));
    fill(128);
    arc(width/2, height/2, 200, 200, (float)-Math.PI/2, (float)(-Math.PI/2) + radians(360 * value / 3300));
    fill(255);
    text(String.format("%04d", (int)Math.round(value)), 10, 75);
  } catch (Exception ex) {
    ex.printStackTrace();
  }
}

void dispose() {
  ads1015.close();
}

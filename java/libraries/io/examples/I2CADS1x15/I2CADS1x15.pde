import processing.io.*;

ADS1x15 ads1015;

ICType ADC_TYPE = ICType.IC_ADS1015;
int gain = pgaADS1x15.ADS1015_REG_CONFIG_PGA_6_144V.meaning(); // +/- 6.144 V
int sps  = spsADS1015.ADS1015_REG_CONFIG_DR_250SPS.meaning();  // 250 Samples per Second

void setup() {
  size(200, 200);
  textSize(72);
  System.setProperty("ads1x15.verbose", "false");
  ads1015 = new ADS1x15(ADC_TYPE);
}

void draw() {
  background(0);
  stroke(255);
  try {
    float value = ads1015.readADCSingleEnded(Channels.CHANNEL_1, gain, sps);
    println(String.format("Value: %f, %.03f V", value, (value / 1000)));
  } catch (Exception ex) {
    ex.printStackTrace();
  }
}

void dispose() {
  ads1015.close();
}

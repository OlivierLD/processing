public class BME280Data {
	float temp = 0f, press = 0f, alt = 0f, hum = 0f;

	public BME280Data(float temp, float press, float alt, float hum) {
		this.temp = temp;
		this.press = press;
		this.alt = alt;
		this.hum = hum;
	}

	public float getTemp() {
		return this.temp;
	}

	public float getPress() {
		return this.press;
	}

	public float getAlt() {
		return this.alt;
	}

	public float getHum() {
		return this.hum;
	}
}

/**
 * This is used to simulate the data, when running on a platform
 * where Hardware-IO is not supported.
 */
static class Simulators {
  
  /**
   * Temperature simulator
   */
  public static class TempSimulator {
    private final static int MINI = -20;
    private final static int MAXI = 50;
    private static double lastTemperature = 20d; // Start at 20
    
    public static double get() {
      int sign = (int)System.currentTimeMillis() % 2;
      double diff = Math.random() * (sign == 0 ? 1 : -1);
      lastTemperature += diff;
      lastTemperature = Math.max(lastTemperature, MINI);
      lastTemperature = Math.min(lastTemperature, MAXI);
      return lastTemperature;
    }
  }

  /**
   * Humidity simulator
   */
  public static class HumSimulator {
    private final static int MINI =   0;
    private final static int MAXI = 100;
    private static double lastHum = 50d; // Start at 50
    
    public static double get() {
      int sign = (int)System.currentTimeMillis() % 2;
      double diff = Math.random() * (sign == 0 ? 1 : -1);
      lastHum += diff;
      lastHum = Math.max(lastHum, MINI);
      lastHum = Math.min(lastHum, MAXI);
      return lastHum;
    }
  }
}

static boolean verbose = ("true".equals(System.getProperty("ads1x.verbose", "false")));

// IC Identifiers
public enum ICType {
  IC_ADS1015,
  IC_ADS1115
}

// Available channels
public enum Channels {
  CHANNEL_0,
  CHANNEL_1,
  CHANNEL_2,
  CHANNEL_3
}

public enum spsADS1115 {
  ADS1115_REG_CONFIG_DR_8SPS(8, ADS1x15.ADS1115_REG_CONFIG_DR_8SPS),
  ADS1115_REG_CONFIG_DR_16SPS(16, ADS1x15.ADS1115_REG_CONFIG_DR_16SPS),
  ADS1115_REG_CONFIG_DR_32SPS(32, ADS1x15.ADS1115_REG_CONFIG_DR_32SPS),
  ADS1115_REG_CONFIG_DR_64SPS(64, ADS1x15.ADS1115_REG_CONFIG_DR_64SPS),
  ADS1115_REG_CONFIG_DR_128SPS(128, ADS1x15.ADS1115_REG_CONFIG_DR_128SPS),
  ADS1115_REG_CONFIG_DR_250SPS(250, ADS1x15.ADS1115_REG_CONFIG_DR_250SPS),
  ADS1115_REG_CONFIG_DR_475SPS(475, ADS1x15.ADS1115_REG_CONFIG_DR_475SPS),
  ADS1115_REG_CONFIG_DR_860SPS(860, ADS1x15.ADS1115_REG_CONFIG_DR_860SPS);

  private final int meaning, value;

  private spsADS1115(int meaning, int value) {
    this.meaning = meaning;
    this.value = value;
  }

  public int meaning() {
    return this.meaning;
  }

  public int value() {
    return this.value;
  }

  public static int setDefault(int val, int def) {
    int ret = def;
    boolean found = false;
    for (spsADS1115 one : values()) {
      if (one.meaning() == val) {
        ret = one.value();
        found = true;
        break;
      }
    }
    if (!found) {
      if (verbose) {
        System.out.println("Value [" + val + "] not found, defaulting to [" + def + "]");
      }
      // Check if default value is in the list
      found = false;
      for (spsADS1115 one : values()) {
        if (one.value() == def) {
          ret = val;
          found = true;
          break;
        }
      }
      if (!found) {
        System.out.println("Just FYI... default value is not in the enum...");
      }
    }
    return ret;
  }
}

public enum spsADS1015 {
  ADS1015_REG_CONFIG_DR_128SPS(128, ADS1x15.ADS1015_REG_CONFIG_DR_128SPS),
  ADS1015_REG_CONFIG_DR_250SPS(250, ADS1x15.ADS1015_REG_CONFIG_DR_250SPS),
  ADS1015_REG_CONFIG_DR_490SPS(490, ADS1x15.ADS1015_REG_CONFIG_DR_490SPS),
  ADS1015_REG_CONFIG_DR_920SPS(920, ADS1x15.ADS1015_REG_CONFIG_DR_920SPS),
  ADS1015_REG_CONFIG_DR_1600SPS(1600, ADS1x15.ADS1015_REG_CONFIG_DR_1600SPS),
  ADS1015_REG_CONFIG_DR_2400SPS(2400, ADS1x15.ADS1015_REG_CONFIG_DR_2400SPS),
  ADS1015_REG_CONFIG_DR_3300SPS(3300, ADS1x15.ADS1015_REG_CONFIG_DR_3300SPS);

  private final int meaning, value;

  private spsADS1015(int meaning, int value) {
    this.meaning = meaning;
    this.value = value;
  }

  public int meaning() {
    return this.meaning;
  }

  public int value() {
    return this.value;
  }

  public static int setDefault(int val, int def) {
    int ret = def;
    boolean found = false;
    for (spsADS1015 one : values()) {
      if (one.meaning() == val) {
        ret = one.value();
        found = true;
        break;
      }
    }
    if (!found) {
      if (verbose) {
        System.out.println("Value [" + val + "] not found, defaulting to [" + def + "]");
      }
      // Check if default value is in the list
      found = false;
      for (spsADS1015 one : values()) {
        if (one.value() == def) {
          ret = val;
          found = true;
          break;
        }
      }
      if (!found) {
        System.out.println("Just FYI... default value is not in the enum...");
      }
    }
    return ret;
  }
}

// Dictionary with the programmable gains
public enum pgaADS1x15 {
  ADS1015_REG_CONFIG_PGA_6_144V(6144, ADS1x15.ADS1015_REG_CONFIG_PGA_6_144V),
  ADS1015_REG_CONFIG_PGA_4_096V(4096, ADS1x15.ADS1015_REG_CONFIG_PGA_4_096V),
  ADS1015_REG_CONFIG_PGA_2_048V(2048, ADS1x15.ADS1015_REG_CONFIG_PGA_2_048V),
  ADS1015_REG_CONFIG_PGA_1_024V(1024, ADS1x15.ADS1015_REG_CONFIG_PGA_1_024V),
  ADS1015_REG_CONFIG_PGA_0_512V( 512, ADS1x15.ADS1015_REG_CONFIG_PGA_0_512V),
  ADS1015_REG_CONFIG_PGA_0_256V( 256, ADS1x15.ADS1015_REG_CONFIG_PGA_0_256V);

  private final int meaning, value;

  private pgaADS1x15(int meaning, int value) {
    this.meaning = meaning;
    this.value = value;
  }

  public int meaning() {
    return this.meaning;
  }

  public int value() {
    return this.value;
  }

  public static int setDefault(int val, int def) {
    int ret = def;
    boolean found = false;
    for (pgaADS1x15 one : values()) {
      if (one.meaning() == val) {
        ret = one.value();
        found = true;
        break;
      }
    }
    if (!found) {
      if (verbose) {
        System.out.println("Value [" + val + "] not found, defaulting to [" + def + "]");
      }
      // Check if default value is in the list
      found = false;
      for (pgaADS1x15 one : values()) {
        if (one.value() == def) {
          ret = val;
          found = true;
          break;
        }
      }
      if (!found) {
        System.out.println("Just FYI... default value is not in the enum...");
      }
    }
    return ret;
  }
}

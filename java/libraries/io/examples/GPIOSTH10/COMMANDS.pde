import java.util.Map;

private static Map<String, Byte> COMMANDS = new HashMap<String, Byte>();

// STH10 commands
private final static String TEMPERATURE_CMD = "Temperature";
private final static String HUMIDITY_CMD = "Humidity";
private final static String READ_STATUS_REGISTER_CMD = "ReadStatusRegister";
private final static String WRITE_STATUS_REGISTER_CMD = "WriteStatusRegister";
private final static String SOFT_RESET_CMD = "SoftReset";
private final static String NO_OP_CMD = "NoOp";

static {
	COMMANDS.put(TEMPERATURE_CMD, (byte)0x03);          // 0b00000011);
	COMMANDS.put(HUMIDITY_CMD,(byte)0x05);              // 0b00000101);
	COMMANDS.put(READ_STATUS_REGISTER_CMD,(byte)0x07);  // 0b00000111);
	COMMANDS.put(WRITE_STATUS_REGISTER_CMD,(byte)0x06); // 0b00000110);
	COMMANDS.put(SOFT_RESET_CMD,(byte)0x1E);            // 0b00011110);
	COMMANDS.put(NO_OP_CMD,(byte)0x00);                 // 0b00000000);
}
